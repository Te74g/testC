function Get-PromotionReviewState {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  $ReviewPath = Join-Path $ProjectRoot ("workers\reviews\{0}\promotion-review.md" -f $WorkerKey)
  if (-not (Test-Path $ReviewPath)) {
    return [pscustomobject]@{
      path = "not_available"
      state = "not_reviewed"
    }
  }

  $Text = Get-Content $ReviewPath -Raw
  $State = "reviewed"
  if ($Text -match '(?m)^- decision:\s*\*\*promote\*\*') {
    $State = "promoted"
  } elseif ($Text -match '(?m)^- decision:\s*\*\*reject\*\*') {
    $State = "rejected"
  }

  return [pscustomobject]@{
    path = $ReviewPath.Replace($ProjectRoot + "\", "")
    state = $State
  }
}

function Get-LatestWorkerArtifactPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$Root,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey,

    [Parameter(Mandatory = $true)]
    [string]$Filter
  )

  $Dir = Join-Path $Root $WorkerKey
  $Latest = Get-ChildItem $Dir -Filter $Filter -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if (-not $Latest) {
    return "not_available"
  }

  return $Latest.FullName.Replace($ProjectRoot + "\", "")
}

function Get-PrimaryWorkerKeyFromDecisionBrief {
  param(
    [Parameter(Mandatory = $true)]
    [string]$DecisionBriefPath
  )

  if (-not (Test-Path $DecisionBriefPath)) {
    throw "decision brief not found: $DecisionBriefPath"
  }

  $DecisionBriefText = Get-Content $DecisionBriefPath -Raw
  if (-not ($DecisionBriefText -match '(?m)^- primary_first_live_patch_candidate:\s*(.+)$')) {
    throw "primary candidate not found in decision brief"
  }

  $WorkerKey = $matches[1].Trim()
  if (-not $WorkerKey -or $WorkerKey -eq "not_available") {
    throw "no valid primary candidate is available"
  }

  return $WorkerKey
}

function Get-LivePatchReadiness {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$WorkerKey
  )

  . (Join-Path (Join-Path $ProjectRoot "scripts") "resolve-worker-patch-proposal.ps1")

  $DecisionBriefPath = Join-Path $ProjectRoot "workers\decision-briefs\latest-worker-patch-decision-brief.md"
  $CatalogPath = Join-Path $ProjectRoot "workers\worker-catalog.v1.json"
  $PreviewRoot = Join-Path $ProjectRoot "workers\prompt-previews"
  $ApprovalRoot = Join-Path $ProjectRoot "workers\approval-requests"
  $Marker = "At the end of each task, report:"

  $Catalog = $null
  if (Test-Path $CatalogPath) {
    $Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
  }
  $Definition = if ($Catalog) { $Catalog.workers.$WorkerKey } else { $null }
  $WorkerName = if ($Definition) { [string]$Definition.worker_name } else { $WorkerKey }
  $CharacterName = if ($Definition) { [string]$Definition.character_name } else { $WorkerKey }
  if (-not $CharacterName) {
    $CharacterName = $WorkerName
  }
  $DisplayName = "{0} ({1})" -f $CharacterName, $WorkerKey

  $PreviewPath = Get-LatestWorkerArtifactPath -ProjectRoot $ProjectRoot -Root $PreviewRoot -WorkerKey $WorkerKey -Filter "*-prompt-preview.md"
  $ApprovalRequestPath = Get-LatestWorkerArtifactPath -ProjectRoot $ProjectRoot -Root $ApprovalRoot -WorkerKey $WorkerKey -Filter "*-patch-approval-request.md"
  $Promotion = Get-PromotionReviewState -ProjectRoot $ProjectRoot -WorkerKey $WorkerKey

  try {
    $ResolvedProposalPath = Resolve-WorkerPatchProposal -ProjectRoot $ProjectRoot -WorkerKey $WorkerKey
    $Proposal = Read-WorkerPatchProposal -ProjectRoot $ProjectRoot -ResolvedProposalPath $ResolvedProposalPath
  } catch {
    return [pscustomobject]@{
      worker_key = $WorkerKey
      display_name = $DisplayName
      worker_name = $WorkerName
      character_name = $CharacterName
      decision_brief_path = $DecisionBriefPath.Replace($ProjectRoot + "\", "")
      proposal_path = "not_available"
      preview_path = $PreviewPath
      approval_request_path = $ApprovalRequestPath
      promotion_review_path = $Promotion.path
      target_prompt_path = "not_available"
      promotion_state = $Promotion.state
      approval_flag = "no"
      marker_present = $false
      insertion_already_present = $false
      overall_state = "blocked_missing_artifact"
      blocking_reason = $_.Exception.Message
    }
  }

  $TargetPromptRelative = $Proposal.target_prompt_relative
  $TargetPromptExists = Test-Path $Proposal.target_prompt_path
  $PromptText = if ($TargetPromptExists) { Get-Content $Proposal.target_prompt_path -Raw } else { "" }
  $MarkerPresent = if ($TargetPromptExists) { $PromptText.Contains($Marker) } else { $false }
  $InsertionAlreadyPresent = if ($TargetPromptExists) { $PromptText.Contains($Proposal.insertion_block) } else { $false }

  $BlockingReason = ""
  $OverallState = "pending_sponsor_approval"

  if ($PreviewPath -eq "not_available" -or $ApprovalRequestPath -eq "not_available" -or -not $TargetPromptExists -or -not $MarkerPresent) {
    $OverallState = "blocked_missing_artifact"
    $BlockingReason = "one or more required artifacts or prompt markers are missing"
  } elseif ($Promotion.state -ne "promoted") {
    $OverallState = "blocked_missing_artifact"
    $BlockingReason = "promotion evidence is not strong enough"
  } elseif ($InsertionAlreadyPresent) {
    $OverallState = "already_applied_or_duplicate_risk"
    $BlockingReason = "target prompt already contains the proposed insertion block"
  } elseif ($Proposal.approved_for_live_patch -eq "yes") {
    $OverallState = "ready_to_apply"
    $BlockingReason = ""
  } else {
    $OverallState = "pending_sponsor_approval"
    $BlockingReason = "proposal is not yet explicitly approved for live patch"
  }

  return [pscustomobject]@{
    worker_key = $WorkerKey
    display_name = $DisplayName
    worker_name = $WorkerName
    character_name = $CharacterName
    decision_brief_path = $DecisionBriefPath.Replace($ProjectRoot + "\", "")
    proposal_path = $ResolvedProposalPath.Replace($ProjectRoot + "\", "")
    preview_path = $PreviewPath
    approval_request_path = $ApprovalRequestPath
    promotion_review_path = $Promotion.path
    target_prompt_path = $TargetPromptRelative
    promotion_state = $Promotion.state
    approval_flag = $Proposal.approved_for_live_patch
    marker_present = $MarkerPresent
    insertion_already_present = $InsertionAlreadyPresent
    overall_state = $OverallState
    blocking_reason = $BlockingReason
  }
}
