using Uno;
using Uno.UX;
using Uno.IO;
using Uno.Testing;
using Uno.Collections;

using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

namespace FuseTest
{
	public class JsTestRecorder : IDisposable
	{
		Queue<AssertResult> _testResults;
		Fuse.Scripting.Context _context;

		public JsTestRecorder() : this(JavaScriptTestContext.Create()) {}

		public JsTestRecorder(Fuse.Scripting.Context context)
		{
			_context = context;
			var f = context.Evaluate("", "(function(obj, assert) { obj['test'] = { assert: function(exp, msg) { try { assert(Boolean(exp ? 1 : 0), msg); } catch(e) { assert(0, 'Error: ' + e); } } }; } )") as Fuse.Scripting.Function;
			f.Call(context.GlobalObject, (Callback)TestAssert);
		}

		public class AssertResult
		{
			public bool Result { get; private set; }
			public string Message { get; private set; }

			public AssertResult(bool result, string msg)
			{
				Result = result;
				Message = msg;
			}
		}
		
		public Fuse.Scripting.Context Begin()
		{
			_testResults = new Queue<AssertResult>();
			return _context;
		}

		public void End()
		{
			Assert.IsTrue(_testResults.Count > 0);

			do
			{
				var test = _testResults.Dequeue();
				Assert.IsTrue(test.Result, "main.js", 0, test.Message);
			} while(_testResults.Count > 0);
		}

		object TestAssert(object[] args)
		{
			var result = false;
			if(args.Length > 0)
				result = Fuse.Marshal.ToBool(args[0]);

			var msg = "";
			if(args.Length > 1)
				msg = (string)args[1];

			_testResults.Enqueue(new AssertResult(result, msg));
			return null;
		}

		public void Dispose()
		{
			if(_context != null)
				_context.Dispose();
		}
	}

	public static class JavaScriptTestContext
	{
		public static void CreateInJavaScriptTag(Action<Fuse.Scripting.Context> call)
		{
			var nt = NameTable.Empty;

			var w1 = new Fuse.Reactive.JavaScript(nt);
			w1.FileName = "Empty JS tag";
			
			var _rootViewport = new TestRootPanel();

			nt.This = _rootViewport;
			_rootViewport.Children.Add(w1);

			var w = Fuse.Reactive.JavaScript.Worker;
			if (w != null)
				w.WaitIdle();

			var context = w.Context;
			call(context);
			_rootViewport.StepFrameJS();
		}

		public static Fuse.Scripting.Context Create()
		{
			var c = Fuse.Reactive.ThreadWorker.CreateContext(null);
			new Fuse.Reactive.FuseJS.Builtins(c);
			return c;
		}
	}
}
