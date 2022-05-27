# oar-site

This is my personal collection of scripts used for generating [Misterblue's OAR collection site](https://misterblue.com/oars).

If you want to run your own copy of this oar display site, you have to edit the content for your repositories into the files.

The 'oar' sub-directory is what is put on the web server.
You will have to edit `index.html` with your specific explanation of the site.
That HTML file includes `oar.js` which builds the table that is displayed.
`oar.js` also has the links to the repository (where all the OARs and GLTF files are stored on the Internet).

`oar.js` expects to read `baseURL + 'index.json'`. That file is built by the scripts in `oar-site/gen`.

`oar-site/gen/run.sh` looks for OAR files in `../../oar-site-oars` which is a directory containing OAR
files and description files of the same name (NAME.jpg, NAME.html).
That is, if there is an OAR file named `frog.oar` and files `frog.jpg` and `frog.html`, the generated
table entry would include the picture and that formatted text as a description of the OAR file.

`run.sh` runs Convoar on each of the OAR files in several simplification modes and creates
the `convoar` output directory.
`oar-site/gen/run.sh` also executes `genIndex.sh` which creates the `index.json` file for the built directories.

That's the basic process. It's not very portable as I never made it easily customizable for a large audience.
