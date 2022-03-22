# Theil-Sen estimator for Matlab

## Description

A fast, stand-alone Theil-Sen estimator for robust regression in Matlab.

### Theil-Sen estimator

A [Theil-Sen estimator](https://en.wikipedia.org/wiki/Theil%E2%80%93Sen_estimator) provides robust linear regression in the 2D plane:
The resulting estimates of slope and intercept are relatively insensitive to outliers.

FIXME: Mention main idea (data point pairs), and resulting complexity.

### No dependency on Matlab toolboxes

This code is based on [Theil-Sen Robust Linear Regression](https://mathworks.com/matlabcentral/fileexchange/48294-theil-sen-robust-linear-regression), version 1.2.0.0, by [Zachary Danziger](https://mathworks.com/matlabcentral/profile/authors/1044524).
It was modified mainly by re-defining its call to the `nanmedian()` function, which creates a dependency on the (commercially licensed) [Statistics Toolbox](https://mathworks.com/products/statistics.html).

There are several other implementations of the Theil-Sen estimator on Mathworks's [File Exchange](https://mathworks.com/matlabcentral/fileexchange).
Unfortunately all were found to depend on the Statistics Toolbox, [except one](https://mathworks.com/matlabcentral/fileexchange/43135-regression-utilities), which was judged to be slower and less versatile.

## Installation

Clone/copy the files to your computer, and add the folder to Matlab's path variable.

## Usage

TODO: Add examples, and show some expected output.

## Roadmap

- Add more documentation.
    - [ ] Mention original use case.
    - [ ] Add usage example and plot.
- [ ] Add a drop-in for `nanmean()` to become independent of Statistics Toolbox.
- [ ] Change input interface to match Matlab's `robustfit()`.
- [ ] Add more checks for input sanity.


## Changelog

- October 2014 by Z. Danziger: Original version.
- September 2015 by Z. Danziger: Updated help, speed increase for 2D case
- March 2022 by J. Keyser: Adjusted formatting, added documentation,

## Contributing and project status

This project is relatively unmaintained, and only shared as-is, in the hope to be helpful.
If you find a bug, feel free to let the author(s) know.
Feature requests should be directed to the original author.

## Authors

1. Zachary Danziger, original author ([Matlab profile](https://de.mathworks.com/matlabcentral/profile/authors/1044524), [Lab webpage](https://anil.fiu.edu/))
2. Johannes Keyser

## License

[Simplified BSD License](https://en.wikipedia.org/wiki/BSD_licenses#2-clause_license_(%22Simplified_BSD_License%22_or_%22FreeBSD_License%22)), see [license.txt](license.txt).
