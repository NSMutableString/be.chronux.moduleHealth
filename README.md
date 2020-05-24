# Module health

## Introduction

This console application is created to verify the health of the modules by checking the component coupling like described in the the book `Clean architecture` by Uncle Bob.

By using a metric like this, you will have an overview about the coupling of the modules and are able to tweak and and follow up modules that appear to be in the zone of pain or the zone of uselessness.

## Quick run

Just check out the the repo and navigate to the testcase folder and execute following from terminal.


```sh
./moduleHealth -m modules.json
```

__Tip:__ use `-csv export_for_scatterplot.csv` to export this data as CSV file to be used in your favorite spreadsheet tool to generate a scatterplot.

## About the metrics

You will find both a stability score and an abstractness score for each module. To understand these values, we need to dive into the following two principles.

### 1) The stabe dependencies principle

We take the `Cartfile` to gather all the dependencies. Since some modules could also have incoming dependencies from other projects. I specified an extra parameter `incomingDependenciesIncrement` to support this known incoming dependencies to get a realistic score.

```
module stability score = outgoing dependencies / ( incoming dependencies + outgoing dependencies )
```

### 2) The stable abstractions principle

At this moment, we scan for `public protocol` to determine the number of abstractions.
To gather all implementations, we scan for both `public struct` and `public class`.

```
module abstractness score = abstractions / ( implementations + abstractions )
```

## Known limitations

- only `.swift` files are scanned for abstracness score, Obj-C not supported.
- Only carthage is supported to gather all the dependencies.
- public enum is ignored