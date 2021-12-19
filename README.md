# kobohr-api-toolkit
R scripts to download and upload data to [KOBO Humanitarian](https://kobo.humanitarianresponse.info/") using the API

Three processes are defined:

1. Importing data directly into R
    * We have given two approaches:
        1. Using [koboloadeR](https://github.com/mrdwab/koboloadeR) package
        1. Without using [koboloadeR](https://github.com/mrdwab/koboloadeR)
    * The downfall of this approach is that you don't have much control over the information you'd like to import, and  can only import the latest version of a form, thus won't be able to view data from the previous versions (if any).
1. Creating and downloading exports from Kobo
    * This is an alternative to importing data directly, and offers more control over the information you'd like to have. The options include:
      1. If you'd like to download data from all versions of the form
      1. The fields/columns you want to be included
      1. The type of export ("csv", "geojson", "xls" or "spss_labels")
    * See [Export Task List](https://kobo.humanitarianresponse.info/exports/) for full list

1. Submitting new data to a specific form in KOBO

1. [Updating Records on KOBO](https://github.com/AntonyRono/kobohr-api-toolkit/blob/main/Updating%20Records%20on%20KOBO.R)

This toolkit only includes functions to perform the most basic tasks (i.e download, export,create,update data), but you can refer to [kobohr_apitoolbox](https://github.com/ppsapkota/kobohr_apitoolbox) for additional functions