using Xunit;

namespace RombSkeleton.Tests
{
	public sealed class UnitTest
	{
		[Fact]
		public void TestTests()
		{
			Assert.Equal(4, 2 +2);
		}

		[Fact]
		public void TestAddInTestClass()
		{
			Assert.Equal(6, new TestClass().Add(4, 2));
		}
	}
}
