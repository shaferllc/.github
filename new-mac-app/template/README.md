# __APP__

__DESC__

## Build

```sh
./make-app.sh          # builds for this Mac, installs to /Applications, launches it
./make-app.sh --dist   # a universal dist/__APP__.app plus a .zip and .dmg
swift test
```

macOS 14+, Swift 6. No third-party dependencies; registration comes from
Shafer LLC's own [swift-licensing](https://github.com/shaferllc/swift-licensing).

## Releasing

Bump `VERSION` in a commit on `main`. The release workflow (the shared
[shaferllc/.github mac-release](https://github.com/shaferllc/.github)) builds
the universal app, signs it with the Developer ID, notarizes and staples it,
and publishes `__APP__-<version>.dmg`, a `.zip`, and a stable-named
`__APP__.dmg`. Run the workflow by hand for a dry run.

If __APP__ starts using Apple Events, the camera, the microphone, calendars,
contacts, photos or location, add `__APP__.entitlements` at the repo root —
the hardened runtime denies them otherwise.

## Registration

Optional and free — nothing is gated on it. **Account… → Register…** opens
shafer.llc; after sign-in the site hands the key back through
`__SLUG__://activate`, and __APP__ checks it and keeps it in the keychain.
Help and Contact Support are in the Help menu.

## License

MIT — see [LICENSE](LICENSE).
