# 1行目の Add-Type は削除しました
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:80/Temporary_Listen_Addresses/")
$listener.Start()

Write-Host "起動中: http://localhost/Temporary_Listen_Addresses/"
Write-Host "止めるときは Ctrl+C"

Start-Process "http://localhost/Temporary_Listen_Addresses/"

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $path = $context.Request.Url.LocalPath.Replace("/Temporary_Listen_Addresses/", "").TrimStart("/")
  if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
  
  $full = Join-Path (Get-Location) $path
  if (Test-Path $full) {
    $bytes = [System.IO.File]::ReadAllBytes($full)
    $ext = [System.IO.Path]::GetExtension($full).ToLower()
    $context.Response.ContentType = if ($ext -eq ".html") { "text/html" } elseif ($ext -eq ".mjs" -or $ext -eq ".js") { "text/javascript" } else { "application/octet-stream" }
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $context.Response.StatusCode = 404
  }
  $context.Response.Close()
}