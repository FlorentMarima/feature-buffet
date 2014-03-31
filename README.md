Feature Buffet
=====================
When writing libraries or big amount of code, we sometimes won't use this or that feature. Process such as JavaScript minification are often not capable of "dropping" some bit of code that won't be used. If your libraries kinda look like buffets, just...
Pick your own meal
---------
#### Get started
The ```featbuff```tool is written is Perl (5, version 16). (Do not ask why !) 
- Grab & install JSON package module (http://search.cpan.org/dist/JSON/lib/JSON.pm )
- /*``sudo make install``*/ Not yet
- you are ready to run ```featbuff --help```
 
#### Example
Let's say we have a javascript library file "input.js", such as :
```
var featureA = function (params) {
    // Impl of feature A
}

var featureB = function (params) {
    // Impl of feature B
}

var featureC = function (params) {
    // Impl of feature C
}
```
What we want to do is annotate each "part" of the file such as
```
@start labelOfFeatureA
var featureA = function (params) {
    // Impl of feature A
}
@end // end of feature A  "block"

@start labelOfFeatureB
var featureB = function (params) {
    // Impl of feature B
}
@end 

@start labelOfFeatureC
var featureC = function (params) {
    // Impl of feature C
}
@end // and so on...
```
And then use the featbuff tool :
```
featbuff --init; 
// Will create a FeatBuffetFile containing a json conf 
// And now we are going to interact with this FeatBuffetFile:
featbuff --set A labelOfFeatureA; 
// Let featbuffet know that a feature A exists, and its label is labelOfFeatureA
featbuff --set B labelOfFeatureB;
featbuff --set C labelOfFeatureC;
featbuff --load input.js output.js;
// Let featbuffet know that the output for input.js is output.js
featbuff --add A;
featbuff --add B;
// "Activate" features A and B. 
```

Finaly, when running ``featbuff``, the output.js generated should look like :
```
var featureA = function (params) {
    // Impl of feature A
}

var featureB = function (params) {
    // Impl of feature B
}
```

You kind of understood, it's a very simple parser. The FeatBuffetFile is required, but you are not obliged to use the featbuffet command options (not combinable) to deal with it (just do it with your bare hands). 
Nevertheless, the options should be quite useful if you want to melt feature-buffet into your workflow (for example using Grunt, Gulp or whatever your task runner is).

/!\ The code is messy, feel free to contribute and make it readable /!\