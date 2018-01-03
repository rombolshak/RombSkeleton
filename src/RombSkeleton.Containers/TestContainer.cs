using System;

namespace RombSkeleton.Containers
{
	public class TestContainer
	{
		public TestContainer(IocContainer container)
		{
			TestClass = container.Register(() => new TestClass());
		}

		public Func<TestClass> TestClass { get; }
	}
}
