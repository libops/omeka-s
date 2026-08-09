<?php

declare(strict_types=1);

$config = parse_ini_file('/var/www/omeka-s/config/database.ini', false, INI_SCANNER_RAW);

if (!is_array($config)) {
    fwrite(STDERR, "could not parse config/database.ini\n");
    exit(2);
}

foreach (['host', 'port', 'user', 'password', 'dbname'] as $key) {
    $value = $config[$key] ?? '';
    if (!is_string($value) || $value === '') {
        fwrite(STDERR, "config/database.ini $key is empty\n");
        exit(2);
    }
    fwrite(STDOUT, $value . "\0");
}
