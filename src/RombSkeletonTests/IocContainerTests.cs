using System;
using RombSkeleton.Containers;
using Xunit;

namespace RombSkeleton.Tests
{
	public sealed class IocContainerTests
	{
		[Fact]
		public void TestNormalRegistration()
		{
			var container = new IocContainer();
			var testClass = container.Register(() => new TestClass());
			container.OnRegistrationComplete();
			Assert.Equal(typeof(TestClass), testClass().GetType());
			Assert.Equal(7, testClass().Add(4, 3));
		}

		[Fact]
		public void TestObjectIsCreatedOnlyOnce()
		{
			var container = new IocContainer();
			var testClass = container.Register(() => new ConstructorCallsCountingClass());
			container.OnRegistrationComplete();
			testClass();
			Assert.Equal(1, ConstructorCallsCountingClass.ConstructorCalls);
			testClass();
			Assert.Equal(1, ConstructorCallsCountingClass.ConstructorCalls);
		}

		[Fact]
		public void TestResolvingNotAllowedBeforeRegistrationCompletion()
		{
			var container = new IocContainer();
			var testClass = container.Register(() => new TestClass());
			Assert.Throws<InvalidOperationException>(() => testClass());
		}

		[Fact]
		public void TestRegistrationIsNotAllowerdAfterCompletion()
		{
			var container = new IocContainer();
			container.Register(() => new TestClass());
			container.OnRegistrationComplete();
			Assert.Throws<InvalidOperationException>(() => container.Register(() => 42));
		}

		[Fact]
		public void TestSameTypesWithDifferentValue()
		{
			var container = new IocContainer();
			var value1 = container.Register(() => 1);
			var value2 = container.Register(() => 2);
			container.OnRegistrationComplete();
			Assert.Equal(1, value1());
			Assert.Equal(2, value2());
		}

		[Fact]
		public void TestObjectWithDependencies()
		{
			var container = new IocContainer();
			var dependency = container.Register(() => new DependencyClass());
			var testClass = container.Register(() => new DependentClass(dependency()));
			container.OnRegistrationComplete();
			Assert.Equal(42, testClass().Value);
		}

		private class ConstructorCallsCountingClass
		{
			public ConstructorCallsCountingClass()
			{
				ConstructorCalls++;
			}

			public static int ConstructorCalls { get; private set; }
		}

		private class DependentClass
		{
			public DependentClass(DependencyClass dependency)
			{
				_dependency = dependency;
			}

			public int Value => _dependency.GetValue();

			private readonly DependencyClass _dependency;
		}

		private class DependencyClass
		{
			public int GetValue() => 42;
		}
	}
}
