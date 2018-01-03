using System;
using System.Diagnostics.CodeAnalysis;
using RombSkeleton.Containers;

namespace RombSkeleton.App
{
	[SuppressMessage("ReSharper", "UnusedMember.Global", Justification = "Application startup")]
	internal static class Program
	{
		// ReSharper disable once UnusedMember.Local
		private static void Main()
		{
			using (var container = new IocContainer())
			{
				var test = new TestContainer(container);
				container.OnRegistrationComplete();

				Console.WriteLine(test.TestClass().Add(4, 3));
				Console.ReadLine();
			}
		}
	}
}
