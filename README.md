# Introduction
The common approach in morphological analysis of dendritic spines is to categorize spines into subpopulations based on whether they are stubby, mushroom, thin, or filopodia. Corresponding cellular models of synaptic plasticity, long-term potentiation, and long-term depression associate synaptic strength with either spine enlargement or spine shrinkage. 

However, there is a lack of methods allowing for an automatic distinction between dendritic spine subpopulations. Although a variety of automatic spine segmentation and feature extraction methods were developed recently, no approaches allowing for an automatic and unbiased distinction between dendritic spine subpopulations and detailed computational models of spine behavior exist. To fill this gap, we provide a software that provide insight into dendritic spine shape taxonomy and transitions in time.

# Software description
We propose an automatic and statistically based method for the unsupervised construction of spine shape taxonomy based on arbitrary features. The taxonomy is utilized in the newly introduced computational model of behavior, which relies on transitions between shapes. Models of two different populations can be compared using supplied bootstrap-based statistical tests. The comparison of shape transition characteristics allows to identify differences between population behaviors. 

## Installation and requirements
The software was implemented with R (version 3.0.2; directory *clustering*) and python (version 2.7; all directories apart from *clustering*). Both are interpreted languages and to run the software an user should install appropriate interpreters that can be freely downloaded from the Internet. What is more, default installations may not contain all required libraries. In such case the user should install them manually. Further details can be found at [python.org](https://www.python.org/) and [R-project](https://www.r-project.org/) or [R-bloggers](http://www.r-bloggers.com/installing-r-packages/). Additionally, authors recommend to work with supplied R scripts in an interactive way using  [Rstudio](https://www.rstudio.com/). 

# Data 
The dataset consists of spines described by a range of features. The feature set can be easily extended by appending new columns to the data file (described below). 

The features that we focused on in our experiments were: 
* length
* head width (denote hw)
* max width location (denote mwl)
* max width (denote mw)
* neck width (denote nw)
* foot
* circumference
* area
* width to length ratio (denote wlr)
* length to width ratio (denote lwr)
* length to area ratio (denote lar)

For each spine, all of features were measured at three different timestamps: t<sub>0</sub> (the time before stimulation), t<sub>1</sub> (10 minutes after t<sub>0</sub>) and t<sub>2</sub> (40 minutes after t<sub>0</sub>). 

## Data format

Below we show an example header for a data file representing our data format. The meaning of the consecutive columns is: 
* `unique_id` - unique identifier
* `nencki_id` - identifier assigned to a spine by the data provider
* `animal_id` - identifier of an animal
* `group_id` - identifier of a group (subpopulation) of spines
* `source0, source10, source40` - consecutive sources for three consecutive timestamps
* `0MIN_length, 0MIN_head_width, ... , 10_MIN_length 10_MIN_head_width, ...` -  feature values for three consecutive timestamps. 

Sample header:
`unique_id nencki_id animal_id group_id source0 source10 source40 0MIN_length 0MIN_head_width 0MIN_max_width_location 0MIN_max_width 0MIN_width_length_ratio 0MIN_length_width_ratio 0MIN_neck_width 0MIN_foot 0MIN_circumference 0MIN_area 0MIN_length_area_ratio 0MIN_mean_brightness 0MIN_x_m 0MIN_y_m 0MIN_mean_brightness_GREEN 0MIN_mean_brightness_BLUE 0MIN_mean_brightness_top_GREEN 0MIN_mean_brightness_top_BLUE 0MIN_mean_brightness_bottom_GREEN 0MIN_mean_brightness_bottom_BLUE 0MIN_membrane_brightness_GREEN 0MIN_membrane_brightness_BLUE 0MIN_BCKG_sub_brght_GREEN 0MIN_BCKG_sub_brght_BLUE 0MIN_in_spine_pearson 10_MIN_length 10_MIN_head_width 10_MIN_max_width_location 10_MIN_max_width 10_MIN_width_length_ratio 10_MIN_length_width_ratio 10_MIN_neck_width 10_MIN_foot 10_MIN_circumference 10_MIN_area 10_MIN_length_area_ratio 10_MIN_mean_brightness 10_MIN_x_m 10_MIN_y_m 10_MIN_mean_brightness_GREEN 10_MIN_mean_brightness_BLUE 10_MIN_mean_brightness_top_GREEN 10_MIN_mean_brightness_top_BLUE 10_MIN_mean_brightness_bottom_GREEN 10_MIN_mean_brightness_bottom_BLUE 10_MIN_membrane_brightness_GREEN 10_MIN_membrane_brightness_BLUE 10_MIN_BCKG_sub_brght_GREEN 10_MIN_BCKG_sub_brght_BLUE 10_MIN_in_spine_pearson 40_MIN_length 40_MIN_head_width 40_MIN_max_width_location 40_MIN_max_width 40_MIN_width_length_ratio 40_MIN_length_width_ratio 40_MIN_neck_width 40_MIN_foot 40_MIN_circumference 40_MIN_area 40_MIN_length_area_ratio 40_MIN_mean_brightness 40_MIN_x_m 40_MIN_y_m 40_MIN_mean_brightness_GREEN 40_MIN_mean_brightness_BLUE 40_MIN_mean_brightness_top_GREEN 40_MIN_mean_brightness_top_BLUE 40_MIN_mean_brightness_bottom_GREEN 40_MIN_mean_brightness_bottom_BLUE 40_MIN_membrane_brightness_GREEN 40_MIN_membrane_brightness_BLUE 40_MIN_BCKG_sub_brght_GREEN 40_MIN_BCKG_sub_brght_BLUE 40_MIN_in_spine_pearson`

As shown above, the separator is space.

### Spines identifiers
Spines identifiers (unique_id column) should be composed of the following parts merged with the separator "-":
* identifier for the dataset (for self-reference, may be 00)
* animal id
* spine id
* a letter denoting control (d) or active (f) group

Example identifier is: `00-001-001-d`

## Balanced subset selection
Large differences between spine groups may influence the
statistical analysis of their behavior. Therefore, we decided to
preprocess the datasets by excluding some spines, such that the
means in the new sets are similar with respect to t-test statistical test. 
Namely, we draw a number of pairs of closest spines,
each pair consisting of a spine from the ACTIVE set and a spine
from the CONTROL. The measure of how close the spines are is
based on the normalized Euclidean distance between the vectors of
features at time t<sub>0</sub>.

The code responsible for this analysis is in package *parsing*. The main script is *filter_spines.py*. The parameters for the algorithm are specified in script *filter_spines_params.py*, where one can set the stop criterion, input and output file names, etc.

## Division of spines by changing characteristics

We consider the relative change in feature length across CONTROL and ACTIVE groups. We observe that spines from the ACTIVE group
compared with CONTROL may exhibit more extreme changes
in descriptor values. Therefore, the regions where ACTIVE is more
frequent than CONTROL could possibly be treated as varying.
This motivates the following criterion for splitting the spines from
both populations into three subgroups: shrinking, not changing
and growing. We choose the two separating points defining the
three sub-groups such that the differences between the counts of
corresponding subgroups from the ACTIVE and CONTROL
populations are maximized.

The code for performing this procedure is in package *histogram*. Script *breaking_points_relative.py* finds the separating points between consecutive sub-groups of the spine groups according to the specified feature. The same script also plots the resulting split on a graph.


## Simplification of shape representations

The initial features describing spines can be reduced with the dimensionality reduction technique to render the data representation to be more compact and simple and to filter out the noise. The code responsible for this analysis can be found in the files *routine_data_preparation.r* and *pca.r*. However, the calculation of the simplified representation was integrated in the main scripts (see below) and should not be run separately. 

# Shape Transition Model

To start working with the model the user first should set the proper working directory. In Rstudio it can be done with: `setwd("PATH-TO-THE-SOFTWARE/clustering/")`. After that the appropriate script can be opened from the menu (File -> Open File) and either executed as a whole or run line after the line with Ctrl+Enter. The authors recommend the second approach as it allows for easy observation of results and the validation of the execution.

## Parameters selection

The selection of parameters (fuzzifier `m` and number of clusters `k`) can be done with the help of the script *script_shape_transitions_parameters_selection.r*. 

The script contains the following parts that should be run consecutively:
* routines and libraries including
* configuration and parameters setting (to be edited by the user by the execution)
* data loading and preparation (including PCA) 
* construction and plotting of errors matrices
* automatic selection of the parameters `k` (number of clusters) and `m` (fuzzifier).

The script is parametrized by the following variables (that should be edited manually by the user):
* `train.data.file` - a path to the input data file
* format-specific parameters:
 * `features.names.t0` - a list of column names of spine features at t<sub>0</sub>
 * `features.names.t1` - a list of column names of spine features at t<sub>1</sub>
 * `features.names.nice` - a list of short names of the features (arbitrary names by the user)
 * `spine.id = "unique_id"` - a name of the column containing spine identifier ()
 * `group.id = "group_id"` - a name of the column containing population identifier (must be a single character)
 * `spine.id.field.separator = "-"` - a character used to separate parts in spine identifiers ("-" by default)
 * `groups.ids` - a list of two characters containing possible names of sub-populations to be compared (see `group.id`)
* PCA-related parameters:
 * `pca.feature.groups` - a list of feature lists. Each sub-list should contain subset of names from `features.names.nice`. Each subset will be considered separately and will be used to produce the output features (named Comp.1, Comp.2, etc.). 
 * `pca.num.features` - a number of PCA features to be generated (there might more than one output feature per each subset of features). 
 * `normalization` - should the output features be normalized with Z-score or not (False by default).
* Clustering-related parameters 
 * `clustering.method` - a name of the clustering method (supported values: hierarchical, cmeans, kmeans)
 * `ms` - a list with `m` (fuzzifier) values to be tested
 * `ks` - a list of `k` (number of clusters) values to be tested
 * `compute.index.value.routine` - a path to the sub-routine that calculates the validation index (WSS by default)
 * `index.label` - a name of the validation index (to be used on the output plots)
* `output.dir` - a path to the directory where output plots and results should be stored


## Clustering and models comparison

The main script is *script_shape_transitions_analysis.r*. The script contains the following parts:
* routines and libraries including
* configuration and parameters setting (to be edited by the user by the execution)
* data loading and preparation (including PCA) 
* K-fold crossvalidation of prediction error estimation on the training data (can be run optionally and both before and after data filtering)
* clustering of the data
* a calculation of transition matrices and errors using bootstrap (can be run both before and after data filtering)
* data filtering to keep only spines from balanced data subset (optional; see below `balanced.ids.file`).
* a calculation of differences between transition matrices 
* a calculation of transition prediction quality with different models

The script is parametrized by the following variables (should be edited manually by the user):
* `train.data.file` - a path to the input data file
* `test.data.file` - a path to the additional test file if available; otherwise should be equal to `train.data.file`
* `balanced.ids.file` - a path to the file with spine identifiers (must contain the column `spine.id`) from the balanced subset of the data (see "Balanced subset selection"). If you want to construct transition matrices for the whole data set this variable to NaN.
* format-specific parameters (see above)
* PCA-related parameters (see above)
* spines visualization:
 * `images.base.dir` - a path to the directory containing source TIFF images of spines. If images are not supplied the variable should be commented out.
 * `spine.image.size` - how big area (measured in number of pixels) around the spine should be plotted
 * `visualise.num.representants` - how many spines per cluster should be plotted
 * `source0` - a name of the column that contains TIFF image name. The file should contain the spine image at t<sub>0</sub>. However, one file can contain many spines.
 * `xpos0` - a name of the column that contains spine's center x-coordinate at the image from `source0` 
 * `ypos0` - a name of the column that contains spine's center y-coordinate at the image from `source0` 
 * `source1` - a name of the column that contains TIFF image name.  The file should contain the spine image at t<sub>1</sub>  (one file can contain many spines).
 * `xpos1` - a name of the column that contains spine's center x-coordinate at the image from `source1` 
 * `ypos1` - a name of the column that contains spine's center y-coordinate at the image from `source1` 
 * `image.features.t0 = c(source0, xpos0, ypos0)` - a list of columns related to spine look at t<sub>0</sub>
 * `image.features.t1 = c(source1, xpos1, ypos1)` - a list of columns related to spine look at t<sub>1</sub> 
* `clustering.method` - a name of the clustering method (supported values: hierarchical, cmeans, kmeans)
* `m` - the fuzzifier value
* `k` - a number of clusters
* parameters related to transition matrices:
 * `TransitionMatrixCalculator = BuildNonnegativeTransitionMatrixLeastSquares` -  how to calculate transitions of elements (for crisp clusterings `BuildTransitionMatrix` can be used as well)
 * `PredictionErrorEstimator = AvgElementError` - how to calculate prediction errors
 * bootstrap parameters for errors estimation and comparing matrices:
  * `num.repetitions` - number of sampled populations for transition errors computation. More is better.
  * `bootstrap.fraction = 1.0` - bootstrap parameter (should not be changed)
  * `num.repetitions.comp.distribution.changes` - number of sampled populations for comparison of relative changes in clusters distribution for subpopulations (groups). More is better.
  * `num.repetitions.comp.trans.matrices` - number of sampled populations for comparison of transition matrices. More is better.
* `k.fold ` - a parameter used for testing prediction error on the training data set using k-fold crossvalidation (number of folds)
* parameters related to plotting transition grahps:
 * `threshold.counts` - min weight of the edge to be plotted (for example 6 spines)
 * `threshold.percents` - min weight percentage of the edge to be plotted (for example 20% of spines)
* `output.dir` - a path to the directory where output plots and results should be stored
