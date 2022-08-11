## PhotoCollectionAndSaliency
Architecture MVC + C allows some separation of concerns, but used as it is mainly due to the time limit. 
MVVM + C would have been preferable, since UIViewControllers in the current implementation are suffering 
from the typical problem - they know too much about the services and frameworks that they use and do too 
much (data source, delegate, etc.). At the very least some of their responsibilities could have been decomposed 
to separate objects and/or custom injected views (at loadView).

## Dependancies
No external dependencies, only native frameworks, but I have had to import AVFoundation which is kind of 
irrelevant to the task to avoid spending extra time on calculating ratio for animating UIImageView contentMode.

## Room for improvements:
- cancel requests for images that are not needed any more. Could be done using progress handler or using 
request number
- more sophisticated prefetching mechanism. The one that is used now - linking prefetching data source of 
the collectionView with the caching mechanism of PHCachingImageManager does not seem to be very effective
- adding proper error propagation and handling, user alerts
- adding logger to remove print statements
- testing UI on different devices / screen sizes
- adding tests
