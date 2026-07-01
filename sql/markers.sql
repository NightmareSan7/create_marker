CREATE TABLE IF NOT EXISTS `markers` (
    `id`         INT         NOT NULL AUTO_INCREMENT,
    `type`       VARCHAR(10) NOT NULL,
    `data`       JSON        NOT NULL,
    `created_at` DATETIME    NOT NULL DEFAULT (UTC_TIMESTAMP()),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;
