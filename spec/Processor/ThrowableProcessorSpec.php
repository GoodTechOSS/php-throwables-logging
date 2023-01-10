<?php

namespace spec\GoodTechnologies\Throwables\Logging\Processor;

use BadFunctionCallException;
use Error;
use GoodTechnologies\Throwables\Logging\Processor\ThrowableProcessor;
use LogicException;
use PhpSpec\ObjectBehavior;
use RuntimeException;

class ThrowableProcessorSpec extends ObjectBehavior
{
    public function it_is_initializable(): void
    {
        $this->shouldHaveType(ThrowableProcessor::class);
    }


    /**
     * @covers \GoodTechnologies\Throwables\Logging\Processor\ThrowableProcessor::__invoke()
     */
    public function it_should_not_modify_record_without_context(): void
    {
        $record = ['message' => 'A log message.'];

        $this
            ->__invoke($record)
            ->shouldReturn($record);
    }


    /**
     * @covers \GoodTechnologies\Throwables\Logging\Processor\ThrowableProcessor::__invoke()
     */
    public function it_should_not_modify_a_record_without_a_throwable(): void
    {
        $record = [
            'message' => 'Another log message.',
            'context' => [
                'without a' => 'throwable',
            ],
        ];

        $this
            ->__invoke($record)
            ->shouldReturn($record);
    }


    /**
     * @covers \GoodTechnologies\Throwables\Logging\Processor\ThrowableProcessor::__invoke()
     */
    public function it_should_add_throwable_details_to_context(): void
    {
        $runtimeException = new RuntimeException('Something went wrong!', 1);
        $runtimeExceptionLine = __LINE__ - 1;

        $record = [
            'message' => 'Another log message.',
            'context' => [
                'with a' => 'throwable',
                'exception' => $runtimeException,
            ],
        ];

        $result = $this->__invoke($record);

        $result['context']->shouldHaveKeyWithValue('exceptionMessage', 'Something went wrong!');
        $result['context']->shouldHaveKeyWithValue('exceptionCode', 1);
        $result['context']->shouldHaveKeyWithValue('exceptionFile', __FILE__);
        $result['context']->shouldHaveKeyWithValue('exceptionLine', $runtimeExceptionLine);
        $result['context']->shouldHaveKey('exceptionTrace');
    }


    /**
     * @covers \GoodTechnologies\Throwables\Logging\Processor\ThrowableProcessor::__invoke()
     */
    public function it_should_add_multidepth_throwable_details_to_context(): void
    {
        $error = new Error('Bad things happened.', 404);
        $errorLine = __LINE__ - 1;

        $runtimeException = new RuntimeException('Something went wrong!', 1, $error);
        $runtimeExceptionLine = __LINE__ - 1;

        $logicException = new LogicException('Oops!', 0, $runtimeException);
        $logicExceptionLine = __LINE__ - 1;

        $record = [
            'message' => 'Another log message.',
            'context' => [
                'with a' => 'throwable',
                'logicException' => $logicException,
            ],
        ];

        $result = $this->__invoke($record);

        $result['context']->shouldHaveKeyWithValue('logicExceptionMessage', 'Oops!');
        $result['context']->shouldHaveKeyWithValue('logicExceptionCode', 0);
        $result['context']->shouldHaveKeyWithValue('logicExceptionFile', __FILE__);
        $result['context']->shouldHaveKeyWithValue('logicExceptionLine', $logicExceptionLine);
        $result['context']->shouldHaveKey('logicExceptionTrace');

        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious0Message', 'Something went wrong!');
        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious0Code', 1);
        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious0File', __FILE__);
        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious0Line', $runtimeExceptionLine);
        $result['context']->shouldNotHaveKey('logicExceptionPrevious0Trace');

        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious1Message', 'Bad things happened.');
        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious1Code', 404);
        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious1File', __FILE__);
        $result['context']->shouldHaveKeyWithValue('logicExceptionPrevious1Line', $errorLine);
        $result['context']->shouldNotHaveKey('logicExceptionPrevious1Trace');
    }
}
