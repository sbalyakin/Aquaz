The deployment scripts should be used in order to increase build number for all project's targets and, to create new tag in git repository and to push all these changes.

How to use:

1. Execute IncreaseBuildNumber.sh:

     sh IncreaseBuildNumber.sh

2. Build Aquaz for Generic iOS device.

3. Make sure there are no errors happen

4. Execute UpdateRepository.sh:

     sh UpdateRepository.sh