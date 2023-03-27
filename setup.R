library(here)
library(icesTAF)
library(curl)
library(utils)

here::i_am("setup.R")



if (file.exists("Amplicon_data/") == FALSE) {
    mkdir(here("Amplicon_data"))
}

if (file.exists("Amplicon_data/")) {
    curl_download("https://aaudk.sharepoint.com/sites/MicrofloraDanica/_layouts/15/download.aspx?UniqueId=6d03107a%2D87c2%2D4769%2D8309%2D18a62165c83b", here("tmp"))
    # unzip(here("tmp", "Amplicon_data.zip"), exdir = ".")

    temp <- tempfile(fileext = ".zip")
    download.file("https://aaudk.sharepoint.com/:f:/r/sites/MicrofloraDanica/Delte%20dokumenter/mfd_pipeline/HT_PAPER/Amplicon_data?csf=1&web=1&e=NjE3rW", temp)
}
