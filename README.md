# shaferllc/.github

Shared GitHub setup for the shaferllc org.

## Mac release — signed and notarized

`.github/workflows/mac-release.yml` is the one release pipeline for every Mac
app. It builds with the app's `./make-app.sh --dist`, signs everything in the
bundle with the Developer ID (hardened runtime, secure timestamp), notarizes
and staples the app and the `.dmg`, verifies the disk image the way a
downloader would, and publishes `<App>-<v>.dmg`, `<App>-<v>.zip` and a
stable-named `<App>.dmg`.

### Adding an app

1. The repo needs a `VERSION` file and a `./make-app.sh --dist` that builds a
   universal `dist/<App>.app`.
2. Copy [`workflow-templates/mac-release.yml`](workflow-templates/mac-release.yml)
   to `.github/workflows/release.yml` (or pick **Mac app release** under
   Actions → New workflow) and set `app:` and `notes:`.
3. If the app uses Apple Events, the camera, the microphone, calendars,
   contacts, photos or location, add `<App>.entitlements` at the repo root —
   the hardened runtime denies those without it, even after the user allows
   them. Example: [ledge/Ledge.entitlements](https://github.com/shaferllc/ledge/blob/main/Ledge.entitlements).
4. Run the workflow by hand (dry run is the default) to prove it signs and
   notarizes, then bump `VERSION` on `main` to release.

### Secrets

`DEVELOPER_ID_P12`, `DEVELOPER_ID_P12_PASSWORD`, `NOTARY_API_KEY`,
`NOTARY_API_KEY_ID` and `NOTARY_API_ISSUER`, set by the *Shafer Signing Setup*
script as org secrets visible to all public repos. On GitHub's free plan org
secrets don't reach private repos, so the script also copies them onto each
private repo that has a `make-app.sh` — re-run it after creating a private app.
