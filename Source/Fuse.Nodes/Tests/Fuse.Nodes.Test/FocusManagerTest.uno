using Uno;
using Uno.Collections;
using Uno.Testing;
using Fuse;
using Fuse.Input;
using FuseTest;
using Fuse.Controls;

namespace Fuse.Test
{
	public class FocusTest : TestBase
	{
		[Test]
		public void CanSetFocusedVisual()
		{
			var dummy = new FocusableVisual();
			var root = new TestRootPanel();
			root.Children.Add(dummy);

			Assert.IsTrue(Focus.IsFocusable(dummy));
			Assert.IsTrue(dummy.IsContextEnabled);
			
			Focus.GiveTo( dummy );
			Assert.AreEqual(dummy, Focus.FocusedVisual);
		}
		
		[Test]
		public void CanNotSetFocusedVisualOnNotIsFocusable()
		{
			var dummy = new NotFocusableVisual();
			var root = new TestRootPanel();
			root.Children.Add(dummy);
			Assert.IsFalse(Focus.IsFocusable(dummy));
			
			Focus.GiveTo( dummy );
			
			Assert.AreEqual(null, Focus.FocusedVisual);
			Assert.AreNotEqual(dummy, Focus.FocusedVisual);
		}
		
		[Test]
		public void CanNotSetFocusedVisualOnNotEnbled()
		{
			var dummy = new NotEnabledVisual();
			var root = new TestRootPanel();
			root.Children.Add(dummy);
			Assert.IsTrue(Focus.IsFocusable(dummy));
			Assert.IsFalse(dummy.IsContextEnabled);
			
			Focus.GiveTo( dummy );
			
			Assert.AreEqual(null, Focus.FocusedVisual); // No Root
			Assert.AreNotEqual(dummy, Focus.FocusedVisual);
		}
		
		[Test]
		public void CanSetFocusedVisualToNull()
		{
			Focus.Release();
			
			Assert.AreEqual(null, Focus.FocusedVisual);
		}

		[Test]
		public void PredictFocus1()
		{
			var root = new TestRootPanel();
			var target = new FocusableVisual();
			root.Children.Add(target);

			var result = PredictFocusDown(root);

			Assert.AreEqual(result, target);

		}

		static Visual PredictFocusDown(Visual visual)
		{
			return FocusPredictStrategy.Predict(visual, FocusNavigationDirection.Down);
		}
		
		class FocusableVisual : Visual
		{
			public FocusableVisual()
			{
				Focus.SetIsFocusable(this, true);
			}

			public override void Draw(DrawContext dc) {}
		}
		
		class NotFocusableVisual : Visual
		{
			public override void Draw(DrawContext dc) {}
		}
		
		class NotEnabledVisual : FocusableVisual
		{
			public NotEnabledVisual()
			{
				IsEnabled = false;
			}
		}
	}
}
