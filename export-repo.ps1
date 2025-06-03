# PowerShell script to export the repository using Repomix
# Based on the user's preferred command pattern

# Get current timestamp in DDMMMHHmm format (e.g., 24FEB1045)
$timestamp = Get-Date -Format "ddMMMyymm"
$timestamp = $timestamp.ToUpper()

# Repository name
$repoName = "the-music-besties"

# Output file path
$outputPath = "C:\Users\Bravo\Downloads\${repoName}_${timestamp}.txt"

# Run Repomix command
Write-Host "Exporting repository to $outputPath..."
npx repomix -o $outputPath

# Check if export was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Export completed successfully!"
    Write-Host "File saved to: $outputPath"
} else {
    Write-Host "Export failed with exit code $LASTEXITCODE"
}
