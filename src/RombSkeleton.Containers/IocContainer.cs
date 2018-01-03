#region Usings

using System;
using Autofac;

#endregion

namespace RombSkeleton.Containers
{
	public sealed class IocContainer : IDisposable
	{
		public IocContainer()
		{
			_builder = new ContainerBuilder();
		}

		public Func<T> Register<T>(Func<T> objectCreator)
		{
			if (_scope != null)
			{
				throw new InvalidOperationException($"Cannot register {typeof(T)}: container registration is complete");
			}

			_builder.Register(_ => objectCreator());
			return GetObjectGetter<T>();
		}

		public void OnRegistrationComplete()
		{
			_container = _builder.Build();
			_scope = _container.BeginLifetimeScope();
		}

		public void Dispose()
		{
			_scope?.Dispose();
			_container?.Dispose();
		}

		private Func<T> GetObjectGetter<T>() =>
			() =>
			{
				if (_scope == null)
				{
					throw new InvalidOperationException($"Cannot resolve {typeof(T)} as objects registration is not complete yet");
				}

				return _scope.Resolve<T>();
			};

		private readonly ContainerBuilder _builder;
		private IContainer _container;
		private ILifetimeScope _scope;
	}
}