## 0.0.8

- fix: order
- fix: make `removeItem` return the removed `T?` item
- feat: add some util functions: `getItem`, `requireItem`, `getItemStream`
- fix: rename `addItem` -> `upsertItem` & use `upserItem` instead of `_mergeItem`
- fix: rename `listDependency` -> `listDependencies`
- fix: rename of remaining `getItemIdUpdated` -> `getItemTrigger`
- fix: rename `getItem` -> `fetchItem`
- feat: add `triggerPredicateReevaluation`

## 0.0.7

- feat: add `when` parameters to `streamOfAsyncData`, also broadcast flag
- feat: `useThrottleCallback`

## 0.0.6

- add refreshItem to LiveList

## 0.0.5

- Refactor LiveList

## 0.0.4

- fix: define fallback defaultEditableTextContextMenuBuilder if behaviour misses it ([#49](https://github.com/Vlabs-development/v_flutter_core/pull/49))

## 0.0.3

- Add `useDelayedExecution`
- Add `optionsViewOpenDirection` to AutocompleteDecoration (passed over to underlying `RawAutocomplete`)

## 0.0.2

- Update README.md

## 0.0.1

- Initial version.
