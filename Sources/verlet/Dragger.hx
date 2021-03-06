package verlet;

import kha.graphics2.Graphics;
import kha.input.Mouse;
import kha.math.Vector2;
import verlet.Verlet.Particle;
import verlet.Verlet.Composite;
import verlet.Verlet.IPlaceable;
import verlet.Constraint.PinConstraint;
import Type.getClass;

using verlet.Vector2Extensions;

class Dragger {
	
	var world:Verlet = Verlet.Instance;
	
	// Mouse Dragging Vars
	public var mouse(get, null) = new Vector2(0,0);
	public function get_mouse() {return mouse;}
	public var draggedEntity(get, null):IPlaceable = null;
	public function get_draggedEntity() {return draggedEntity;}
	
	private var selectionRadius = 20;
	
	public static var Instance(get, null):Dragger = null;
	private static function get_Instance():Dragger {
		if (Instance == null) {
			new Dragger();
		}
		return Instance;
	}
	
	public function new() {
		Instance = this;
		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
	}
	
	// Handle Dragging
	public function nearestEntity():IPlaceable {
		var d2Nearest = 0.0;
		var entity:IPlaceable = null;
		var constraintsNearest:Array<Constraint> = [];
		
		// find nearest point
		for (c in world.composites) {
			var particles = c.particles;
			for (p in particles) {
				var d2 = p.pos.distanceTo(this.mouse);
				if (d2 <= this.selectionRadius && (entity == null || d2 < d2Nearest)) {
					entity = p;
					constraintsNearest = c.constraints;
					d2Nearest = d2;
				}
			}
		}
		
		for (c in constraintsNearest)
		{
			if (getClass(c) == PinConstraint)
			{
				if (cast(c, PinConstraint).a == entity)
					entity = cast(c, IPlaceable);
			}
		}
		
		return entity;
	}
	
	function onMouseDown(button:Int, x:Int, y:Int):Void {
		this.draggedEntity = nearestEntity();
	}
	
	function onMouseUp(button:Int, x:Int, y:Int):Void {
		this.draggedEntity.pos = new Vector2(x, y); //stamp down as new value or else Pins will stick to mouse
		this.draggedEntity = null;
	}
	
	function onMouseMove(x:Int, y:Int, cx:Int, cy:Int):Void {
		this.mouse.x = x;
		this.mouse.y = y;
	}
}