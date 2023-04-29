# AutoUpdatePS

Proof of concept; a self updating .ps1

## Test

Run the version you're on:

```powershell
.\Invoke-Thing.ps1 -Name Alice
```

Since you're on a git repo, roll back to the prior version:

```shell
git checkout HEAD~1 Invoke-Thing.ps1
```

Run what you have without version check:

```powershell
.\Invoke-Thing.ps1 -Name Bob -Execute
```

Run what you have with version check:

```powershell
.\Invoke-Thing.ps1 -Name Chuck
```
