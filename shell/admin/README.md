# Admin Utilities

`reset-user.sh` resets a Debian-style user account to a clean working state by deleting and recreating the user with a fresh home, `/bin/bash`, default working groups, and an interactive `passwd` prompt.

Examples:

```bash
sudo bash shell/admin/reset-user.sh --user poet --dry-run
sudo bash shell/admin/reset-user.sh --user poet --yes-reset-user
```
