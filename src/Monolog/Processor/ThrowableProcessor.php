<?php
declare(strict_types=1);

namespace GoodTechnologies\Throwables\Logging\Monolog\Processor;

use Throwable;

class ThrowableProcessor
{
    public function __invoke(array $record): array
    {
        foreach ($record['context'] ?? [] as $key => $value) {
            if (!$value instanceof Throwable) {
                continue;
            }

            $record['context'] += [
                "{$key}Message" => $value->getMessage(),
                "{$key}Code" => $value->getCode(),
                "{$key}File" => $value->getFile(),
                "{$key}Line" => $value->getLine(),
                "{$key}Trace" => $value->getTraceAsString(),
            ];

            $current = $value->getPrevious();
            $i = 0;
            while ($current instanceof Throwable) {
                $record['context'] += [
                    "{$key}Previous{$i}Message" => $current->getMessage(),
                    "{$key}Previous{$i}Code" => $current->getCode(),
                    "{$key}Previous{$i}File" => $current->getFile(),
                    "{$key}Previous{$i}Line" => $current->getLine(),
                ];
                ++$i;
                $current = $current->getPrevious();
            }
        }

        return $record;
    }
}
