#############################################
# Create databases e tables in MySQL server #
#############################################

library(Rfuns)

dbn <- 'us_neiss'
dd_create_db(dbn)

## TABLE <attributes> -----------------
x <- "
    `name` CHAR(12) NOT NULL,
    `value` CHAR(7) NOT NULL,
    `label` CHAR(30) NOT NULL,
    `ordering` TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`name`, `value`),
    KEY `ordering` (`ordering`)
"
dd_create_dbtable('vars', dbn, x)

## TABLE <population> -----------------
x <- "
    `year` SMALLINT UNSIGNED NOT NULL,
    `sex` CHAR(1) NOT NULL,
    `age` TINYINT NOT NULL,
    `value` MEDIUMINT NOT NULL,
    PRIMARY KEY (`year`, `sex`, `age`)
"
dd_create_dbtable('population', dbn, x)

## TABLE <adults> -----------------
x <- "
    `id` INT UNSIGNED NOT NULL,
    `weight` DECIMAL(6, 4) UNSIGNED NOT NULL,
    `date` DATE NOT NULL,
    `sex` TINYINT UNSIGNED NOT NULL,
    `age` TINYINT UNSIGNED NOT NULL,
    `race` TINYINT UNSIGNED NULL DEFAULT NULL,
    `disposition` TINYINT UNSIGNED NOT NULL,
    `location` TINYINT UNSIGNED NULL DEFAULT NULL,
    `fad` TINYINT UNSIGNED NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `date` (`date`) USING BTREE,
    KEY `sex` (`sex`),
    KEY `age` (`age`) USING BTREE,
    KEY `race` (`race`),
    KEY `disposition` (`disposition`),
    KEY `location` (`location`),
    KEY `fad` (`fad`)
"
dd_create_dbtable('adults', dbn, x)

## TABLE <infants> -----------------
x <- "
    `id` INT UNSIGNED NOT NULL,
    `weight` DECIMAL(6, 4) UNSIGNED NOT NULL,
    `date` DATE NOT NULL,
    `sex` TINYINT UNSIGNED NOT NULL,
    `age` TINYINT UNSIGNED NOT NULL,
    `race` TINYINT UNSIGNED NULL DEFAULT NULL,
    `disposition` TINYINT UNSIGNED NOT NULL,
    `location` TINYINT UNSIGNED NULL DEFAULT NULL,
    `fad` TINYINT UNSIGNED NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `date` (`date`) USING BTREE,
    KEY `sex` (`sex`),
    KEY `age` (`age`) USING BTREE,
    KEY `race` (`race`),
    KEY `disposition` (`disposition`),
    KEY `location` (`location`),
    KEY `fad` (`fad`)
"
dd_create_dbtable('infants', dbn, x)

## TABLE <products> -----------------
x <- "
    `id` INT UNSIGNED NOT NULL,
    `product` MEDIUMINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`, `product`),
    KEY `product` (`product`)
"
dd_create_dbtable('products', dbn, x)

## TABLE <body_parts> -----------------
x <- "
    `id` INT UNSIGNED NOT NULL,
    `body_part` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`, `body_part`),
    KEY `body_part` (`body_part`)
"
dd_create_dbtable('body_parts', dbn, x)

## TABLE <diagnosis> -----------------
x <- "
    `id` INT UNSIGNED NOT NULL,
    `diagnosis` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`, `diagnosis`),
    KEY `diagnosis` (`diagnosis`)
"
dd_create_dbtable('diagnosis', dbn, x)

## END --------------------------------
rm(list = ls())
gc()
