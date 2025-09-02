<?php
declare(strict_types=1);

namespace GoodTechnologies\Throwables\Logging\Monolog\Processor;

use Monolog\LogRecord;
use Monolog\Processor\ProcessorInterface;
use Throwable;

use function get_class;

class ThrowableProcessor implements ProcessorInterface
{
    public function __invoke(LogRecord $record): array
    {
        foreach ($record['context'] ?? [] as $key => $value) {
            if (!$value instanceof Throwable) {
                continue;
            }

            $record['context'] += [
                "{$key}Class" => get_class($value),
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
                    "{$key}Previous{$i}Class" => get_class($current),
                    "{$key}Previous{$i}Message" => $current->getMessage(),
                    "{$key}Previous{$i}Code" => $current->getCode(),
                    "{$key}Previous{$i}File" => $current->getFile(),
                    "{$key}Previous{$i}Line" => $current->getLine(),
                ];
                ++$i;
                $current = $current->getPrevious();
            }

            unset($record['context'][$key]);
        }

        return $record;
    }
}
