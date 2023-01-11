<?php

namespace GoodTechnologies\Throwables\Logging\Tests\Functional\Monolog\Processor;

use GoodTechnologies\Throwables\Logging\Monolog\Processor\ThrowableProcessor;
use GoodTechnologies\Throwables\Logging\Tests\FunctionalActor;
use Monolog\Handler\TestHandler;
use Monolog\Logger;
use RuntimeException;

class ThrowableProcessorCest
{
    /** @var Logger */
    private $logger;
    private $testHandler;


    public function _before(FunctionalActor $I): void
    {
        $this->logger = (new Logger('app'))
            ->pushProcessor(new ThrowableProcessor());

        $this->testHandler = new TestHandler();

        $this->logger->pushHandler($this->testHandler);
    }


    public function testThatTheHandledMessageContainsTheCorrectThrowableContext(FunctionalActor $I): void
    {
        $runtimeException = new RuntimeException('A bad thing happened.', 1);
        $runtimeExceptionLine = __LINE__ - 1;

        $this->logger->info(
            'This is a log message.',
            [
                'some' => 'context',
                'exception' => $runtimeException,
            ],
        );

        $I->assertTrue(
            $this->testHandler->hasInfo(
                [
                    'message' => 'This is a log message.',
                    'context' => [
                        'some' => 'context',
                        'exceptionClass' => RuntimeException::class,
                        'exceptionMessage' => 'A bad thing happened.',
                        'exceptionCode' => 1,
                        'exceptionFile' => __FILE__,
                        'exceptionLine' => $runtimeExceptionLine,
                        'exceptionTrace' => $runtimeException->getTraceAsString(),
                    ],
                ],
            ),
        );
    }
}
