# Theil-Sen estimator for Matlab

[![View Theil-Sen Robust Linear Regression on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/132443-theil-sen-robust-linear-regression)

## Description

A stand-alone Theil-Sen estimator for robust simple regression in Matlab.

("Stand-alone" means that no toolbox is required.)

### Theil-Sen estimator

A [Theil-Sen estimator](https://en.wikipedia.org/wiki/Theil%E2%80%93Sen_estimator) provides robust linear regression for one predictor:
The resulting estimates of slope and intercept are relatively insensitive to outliers.

The implementation in [TheilSen.m](TheilSen.m) is exact but naïve:
It generates the set of all pairs of the _n_ input samples, resulting in an overall complexity of _O(n²)_ in speed and space.
The resulting slope and offset are the median slope and offset of the lines defined by all data point pairs.  
(Note that alternative implementations of the algorithm have lower complexity, and are thus much faster for large amounts of input samples.)

### No toolbox required

This code is based on [Theil-Sen Robust Linear Regression](https://mathworks.com/matlabcentral/fileexchange/48294-theil-sen-robust-linear-regression), version 1.2.0.0, by Zachary Danziger (which in turn is based on [Theil–Sen estimator](https://de.mathworks.com/matlabcentral/fileexchange/34308-theil-sen-estimator), version 1.0.0.0 by Arnout Tilgenkamp).
Note that these previous versions depend on the (commercially licensed) [Statistics Toolbox](https://mathworks.com/products/statistics.html).

This version uses `median(X, 'omitnan')` instead of `nanmedian(X)` to avoid dependency on the Statistics Toolbox.

See the [changelog](#changelog) below for further modifications.

## Installation

Copy the files to your computer, and add the folder to Matlab's path variable.

## Usage

Please refer to the comments in the header lines of [TheilSen.m](TheilSen.m).

### Example

The script [example.m](example.m) simulates data based on known, "true" values with minor, additive Gaussian noise.
The data are then corrupted with a small percentage of outliers.

The data are fit with the Theil-Sen estimator and least squares, for comparison.
Note how a few "unlucky" outliers can bias the least squares estimate (LS), but have little effect on the Theil-Sen estimator (TS).

<img src="example.svg" alt="plot from example.m" width=500px />

## Changelog

- December 2011 by A. Tilgenkamp: Release of version 1.0.0.0 on Mathworks File Exchange.
- September 2015 by Z. Danziger: Updated help, speed increase for 2D case
- March 2022 by J. Keyser: Adjusted formatting, added documentation, improved example and added plot, replaced `nanmedian(X)` with `median(X, 'omitnan')`, removed 2D special case, restructured input and output parameters.
- August 2022 by J. Keyser: Explicit omission of identical x coordinates, added coefficient of determination (unadjusted R²) as optional output.
- August 2023 by J. Keyser: Add documentation about original author of version 1.0.0.0.

## Contributing and project status

This project is considered complete and is relatively unmaintained.
It is shared as-is in the hope to be helpful (see [license.txt](license.txt) for legal terms).

If you find a bug, please let the author(s) know.

## Authors

- Arnout Tilgenkamp ([Matlab profile](https://mathworks.com/matlabcentral/profile/authors/1561419))
- Zachary Danziger ([Matlab profile](https://de.mathworks.com/matlabcentral/profile/authors/1044524)
- Johannes Keyser ([Matlab profile](https://mathworks.com/matlabcentral/profile/authors/2267277))

## License

[BSD 2-clause simplified license](https://en.wikipedia.org/wiki/BSD_licenses#2-clause_license_(%22Simplified_BSD_License%22_or_%22FreeBSD_License%22)), see [license.txt](license.txt).
