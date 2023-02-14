#include "../../src/multiplication/multiplication.h"
#include "test_multiplication.h"

void
test_multiplication::test_mult()
{
	int expected = 2, result = multiplication::multiply(1, 1);

	CPPUNIT_ASSERT_EQUAL(expected, result);
}
