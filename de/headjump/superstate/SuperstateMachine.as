package de.headjump.superstate {

public class SuperstateMachine extends Superstate {
  private var _paths:Vector.<SuperstateMatchineStatePathInfo>;
  private var _current_enter_path:Array;
  private var _current_exit_path:Array;
  private var _current:Superstate;
  private var _current_from:Superstate;
  private var _current_to:Superstate;

  public function SuperstateMachine(states:Object = null) {
    super(null, states);

    _current_exit_path = null;
    _current_enter_path = null;
    _current_from = null;
    _current_to = null;
    _current = null;

    _paths = new Vector.<SuperstateMatchineStatePathInfo>();
    populatePaths(this, []);

    trace("MACHINE:\n" + this);
  }

  /**
   * Fill paths info with states and all their parents
   */
  private function populatePaths(current:Superstate, path_to_root:Array):void {
    var path_to_root_with_self:Array = path_to_root.concat([current]);
    for(var k:String in current.states) {
      if(current.states.hasOwnProperty(k)) {
        var s:Superstate = current.states[k];
        s.name = k;
        s.machine = this;
        _paths.push(new SuperstateMatchineStatePathInfo(s, path_to_root_with_self));
        populatePaths(s, path_to_root_with_self);
      }
    }
  }

  /**
   * Find first state matching name String (e.g "walking" or "shotgun.primary")
   * @param name
   * @return
   */
  public function stateByName(name:String):Superstate {
    for each(var s:SuperstateMatchineStatePathInfo in _paths) {
      if(s.matches(name)) return s.state;
    }
    return null;
  }

  public function get current_exit_path():Array { return _current_exit_path; }
  public function get current_enter_path():Array { return _current_enter_path; }
  public function get current():Superstate { return _current; }
  public function get current_from():Superstate { return _current_from; }
  public function get current_to():Superstate { return _current_to; }

  public function to(state_name:String):SuperstateMachine {
    var target:Superstate = stateByName(state_name);
    if(!target || target === current) return this; // state not found || already there: do nothing

    _current_from = current;
    _current_to = target;
    var paths:Array = pathFromTo(current, target);
    _current_exit_path = paths[0];
    _current_enter_path = paths[0];

    // move along paths

    // reset
    _current_from = null;
    _current_to = null;
    _current_exit_path = null;
    _current_enter_path = null;
    _current = target;

    return this;
  }

  /**
   * Calc path, split in to path-where-to-exit-states and paths-where-to-enter-states
   * @param from
   * @param to
   * @return
   */
  private function pathFromTo(from:Superstate, to:Superstate):Array {
    if(!(!!from && !!to)) return null;

    var from_root_path:Array = SuperstateMatchineStatePathInfo(from.machine_path_info).parents;
    var to_root_path:Array = SuperstateMatchineStatePathInfo(to.machine_path_info).parents;

    var max_i:int = Math.max(from_root_path.length, to_root_path.length);
    for(var i:int = 0; i < max_i; i++) {

    }

    return [[],[]];
  }

  public function toString():String {
    return _paths.join("\n");
  }
}
}

import de.headjump.superstate.Superstate;

class SuperstateMatchineStatePathInfo {
  private var _me:Superstate;
  private var _parents:Array;
  private var _string_path:String;

  public function SuperstateMatchineStatePathInfo(self:Superstate, parents:Array) {
    _me = self;
    _parents = parents;
    _string_path = "." + parents.map(function(el:Superstate, ...ignore):String { return el.name; }) + _me.name + ".##";
  }

  public function get state():Superstate { return _me; }
  public function get parents():Array { return _parents; }

  public function toString():String { return _string_path; }//.substring(1, -3); }

  public function matches(name:String):Boolean {
    return _string_path.indexOf("." + name + ".##") !== -1;
  }
}