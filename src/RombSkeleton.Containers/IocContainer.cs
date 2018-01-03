#region Usings

using System;
using System.Collections.Generic;

#endregion

namespace RombSkeleton.Containers
{
	public sealed class IocContainer : IDisposable
	{
		public Func<T> Register<T>(Func<T> objectCreator)
		{
			if (_isRegistrationComplete)
			{
				throw new InvalidOperationException($"Cannot register {typeof(T)}: container registration is complete");
			}

			var id = Guid.NewGuid();
			_registeredObjects.Add(id, new Lazy<object>(() => objectCreator()));
			return GetObjectGetter<T>(id);
		}

		public void OnRegistrationComplete()
		{
			_isRegistrationComplete = true;
		}

		public void Dispose()
		{
			foreach (var registeredObject in _registeredObjects)
			{
				(registeredObject.Value.Value as IDisposable)?.Dispose();
			}
		}

		private Func<T> GetObjectGetter<T>(Guid id) =>
			() =>
			{
				if (!_isRegistrationComplete)
				{
					throw new InvalidOperationException($"Cannot resolve {typeof(T)} as objects registration is not complete yet");
				}

				return (T)_registeredObjects[id].Value;
			};

		private bool _isRegistrationComplete;
		private readonly Dictionary<Guid, Lazy<object>> _registeredObjects = new Dictionary<Guid, Lazy<object>>();
	}
}