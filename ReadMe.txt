Hello !

This is a basic Weather App where you can see weather at your current location or any other city in USA

Weather API Credits : https://openweathermap.org/api/

Known facts/issues : 
1. The code can be further modularised with respect to the Views making more into a MVVM pattern.
2. Works for all orientations and size classes. 
3. UI could be made more beautiful
4. Due to time constraints, unit test cases couldn't be added
5. In case of internet failure or any error , a seperate transluscent view can be poped up which is more gracious
6. Image view url download should have been modularised seperately
7. Works for the latest version of iOS only. Backward compatibility not considered yet.
8. simulator screenshot added as seperate file
9. Apple provide CLGeoCoder to do forward and reverse geocoding. So i have used that rather than the openWeather GeoCoding API, to reduce unnecessary API     calls
