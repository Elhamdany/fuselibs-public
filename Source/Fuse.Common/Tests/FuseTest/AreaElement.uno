using Uno;
using Fuse;
using Fuse.Controls;
using Fuse.Elements;

namespace FuseTest
{
	/**
		A control to mimic how wrapping text layout behaves: it increase in height as the width decreases.
	*/
	public class AreaElement : Element
	{
		public float Area { get; set; }
		
		protected override float2 GetContentSize( LayoutParams lp )
		{
			if (lp.HasX)
				return float2( lp.X, Area/lp.X );
			else if (lp.HasY)
				return float2( Area/lp.Y, lp.Y );
			else if (lp.HasMaxX)
				return float2( lp.MaxX, Area/lp.MaxX);
			else if (lp.HasMaxY)
				return float2( Area/lp.MaxY, lp.MaxY);

			return float2(Math.Sqrt(Area));
		}
		
		protected override void OnDraw(Fuse.DrawContext dc) { }
	}
}
