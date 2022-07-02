Rfuns::load_pkgs('data.table', 'fst', 'readxl')

in_path <- file.path(ext_path, 'us', 'NEISS')
out_path <- file.path(dataus_path, 'neiss')

save_dts <- function(y, fn, fst_path, as_rdb = TRUE, dbn = NULL, as_rda = TRUE, csv_in_pkg = TRUE, csv2zip = FALSE){
    write_fst(y, file.path(fst_path, fn))
    if(as_rdb) dd_dbm_do(dbn, 'w', fn, y)
    if(csv_in_pkg){
        fwrite(y, paste0('./data-raw/', fn, '.csv'))
        if(csv2zip){
            zip(paste0('./data-raw/', fn, '.csv.zip'), paste0('./data-raw/', fn, '.csv'))
            file.remove(paste0('./data-raw/', fn, '.csv'))
        }
    }
    if(as_rda){
        assign(fn, y)
        save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
    }
}

# read and bind all excel files
y <- rbindlist(lapply(
            2:21, 
            \(x){
                message('Processing ', x)
                y <- read_xlsx(file.path(in_path, paste0('neiss', x + 2000, '.xlsx')), 1) |> as.data.table() |> setnames(1, 'id')
                y[, c('Stratum', 'PSU', grep('Other', names(y), value = TRUE)) := NULL]
                if(sum(grepl('Narrative_1', names(y))) > 0) setnames(y, 'Narrative_1', 'Narrative')
                y
            }
))
y <- y[!(is.na(Age) | is.na(Sex) | is.na(Disposition))]

# separate all vars with multiple columns, plus narratives 
yb <- rbindlist(list( y[, .(id, body_part = Body_Part)], y[!is.na(Body_Part_2), .(id, body_part = Body_Part_2)] ))
yb[body_part == 87, body_part := NA]
yd <- rbindlist(list( y[, .(id, diagnosis = Diagnosis)], y[!is.na(Diagnosis_2), .(id, diagnosis = Diagnosis_2)] ))
yd[diagnosis == 70, diagnosis := 71]
yp <- rbindlist(list( y[, .(id, product = Product_1)], y[Product_2 > 0, .(id, product = Product_2)], y[Product_3 > 0, .(id, product = Product_3)] ))
yn <- y[, .(id, narrative = Narrative)]
y[, c('Body_Part', 'Body_Part_2', 'Diagnosis', 'Diagnosis_2', 'Product_1', 'Product_2', 'Product_3', 'Narrative') := NULL]

# cleaning
setnames(y, c('id', 'date', 'age', 'gender', 'race', 'hisp', 'disposition', 'location', 'fire', 'alcohol', 'drugs', 'weight'))
y[, date := as.Date(date)]
y[age == 0, age := NA]
y[, sex := NA_character_][gender %in% 1:2, sex := ifelse(gender == 1, 'M', 'F')][, gender := NULL]
y[race == 0, race := NA]
y[race == 3, race := 9]
y[hisp == 1, race := 3]
y[, hisp := NULL]
y[disposition == 9, disposition := NA]
y[location == 0, location := NA]

# create FAD
y[, fad := fire + alcohol * 10 + drugs * 100]
y[, c('fire', 'alcohol', 'drugs') := NULL]
# y[fire == 0, fire := NA]
# y[fire == 2, fire := 0]
# y[fire == 3, fire := 2]

setcolorder(y, c('id', 'weight', 'date', 'age', 'sex'))

# create "infants" and recode monthly ages into two yearly class
yi <- y[age > 200][, age := age - 200]
y[age >= 212, age := 1]
y[age >= 200, age := 0]

# saving: as fst (in public/data), as rda (in package), as csv.zip (in data-raw)
save_dts(yb, 'body_parts', out_path, csv2zip = TRUE)
save_dts(yd, 'diagnosis', out_path, csv2zip = TRUE)
save_dts(yp, 'products', out_path, csv2zip = TRUE)
save_dts(yi, 'infants', out_path, csv2zip = TRUE)
save_dts(yn, 'narratives', out_path, as_rda = FALSE, csv_in_pkg = FALSE)
save_dts(y, 'adults', out_path, csv2zip = TRUE)

# US population by year, sex, and age
tmpf <- tempfile()
tmpd <- tempdir()
download.file('https://www2.census.gov/programs-surveys/international-programs/about/idb/idbzip.zip', tmpf)
unzip(tmpf, exdir = tmpd)
yc <- fread(file.path(tmpd, 'idbsingleyear.all'))
unlink(tmpd)
unlink(tmpf)
yc <- yc[FIPS == 'US', c(1:3, 8)]
setnames(yc, c('year', 'sex', 'value', 'age'))
yc <- yc[year >= 2002 & year <= 2021]
yc <- yc[sex > 0]
setcolorder(yc, c('year', 'sex', 'age'))
save_dts(yc, 'population', out_path)

# clean and exit
rm(list = ls())
gc()
