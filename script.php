<?php

$redis = new Redis();

try {
    $redis->connect('127.0.0.1', 6379);
} catch (Exception $e) {
    die("Не удалось подключиться к Redis: " . $e->getMessage() . PHP_EOL);
}

$lockKey = 'my_script_lock';
$lockTtl = 10; // TTL на всякий случай больше 5 секунд (если скрипт зависнет)

// Попытка установить lock с флагами NX (не перезаписывать) и EX (время жизни)
$lockAcquired = $redis->set($lockKey, 1, ['nx', 'ex' => $lockTtl]);

if (!$lockAcquired) {
    echo "Скрипт уже выполняется. Повторный запуск невозможен." . PHP_EOL;
    exit;
}

echo "Скрипт запущен..." . PHP_EOL;

// Симуляция долгой задачи
sleep(5);

echo "Скрипт завершен." . PHP_EOL;

// Снятие блокировки
$redis->del($lockKey);
