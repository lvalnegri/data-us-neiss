Rfuns::load_pkgs('data.table', 'fst', 'readxl')

in_path <- file.path(ext_path, 'us', 'NEISS')
out_path <- file.path(app_path, 'NEISS')

y <- rbindlist(lapply(
            2:21, 
            \(x){
                message('Processing ', x)
                y <- read_xlsx(file.path(in_path, paste0('neiss', x + 2000, '.xlsx')), 1) |> as.data.table() |> setnames(1, 'id')
                y[, grep('Other', names(y), value = TRUE) := NULL]
                if(sum(grepl('Narrative_1', names(y))) > 0) setnames(y, 'Narrative_1', 'Narrative')
                y
            }
))

yb <- rbindlist(list( y[, .(id, body_part = Body_Part)], y[!is.na(Body_Part_2), .(id, body_part = Body_Part_2)] ))
yd <- rbindlist(list( y[, .(id, diagnosis = Diagnosis)], y[!is.na(Diagnosis_2), .(id, diagnosis = Diagnosis_2)] ))
yp <- rbindlist(list( y[, .(id, product = Product_1)], y[!is.na(Product_2), .(id, product = Product_2)], y[!is.na(Product_3), .(id, product = Product_3)] ))
y[, c('Body_Part', 'Body_Part_2', 'Diagnosis', 'Diagnosis_2', 'Product_1', 'Product_2', 'Product_3') := NULL]

setnames(y, c('id', 'date', 'age', 'sex', 'race', 'hisp', 'disposition', 'location', 'fire_inv', 'alcohol', 'drugs', 'narrative', 'stratum', 'psu', 'weight'))

y[, date := as.Date(date)]
y[age == 0, age := NA]
y[sex %in% c(0, 3), sex := NA]
y[race == 0, race := NA]
y[race == 3, race := 9]
y[hisp == 1, race := 3]
y[, hisp := NULL]
y[disposition == 9, disposition := NA]
y[location == 0, location := NA]
y[fire_inv %in% c(1, 2), fire_inv := NA]
y[alcohol == 0, alcohol := 1]
y[alcohol %in% c(1, 2), alcohol := NA]
y[drugs == 0, drugs := 1]
y[drugs %in% c(1, 2), drugs := NA]

write_fst(yb, file.path(out_path, 'body_parts'))
write_fst(yd, file.path(out_path, 'diagnosis'))
write_fst(yp, file.path(out_path, 'products'))
write_fst(y, file.path(out_path, 'dataset'))

