package de.headjump.superstate {
import de.headjump.superstate.Superstate;

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
  }

  /**
   * Fill paths info with states and all their parents
   */
  private function populatePaths(current:Superstate, path_from_root:Array):void {
    for(var k:String in current.states) {
      if(current.states.hasOwnProperty(k)) {
        var s:Superstate = current.states[k];
        s.name = k;
        s.setMachine(this);
        var info:SuperstateMatchineStatePathInfo = new SuperstateMatchineStatePathInfo(s, path_from_root);
        s.machine_path_info = info;
        _paths.push(info);
        populatePaths(s, path_from_root.concat([s]));
      }
    }
  }

  /**
   * Find first state matching name String (e.g "walking" or "shotgun.primary")
   * @param name
   * @return
   */
  public function stateByName(name:String):Superstate {
    var res:Superstate = null;
    for each(var s:SuperstateMatchineStatePathInfo in _paths) {
      if(s.matches(name)) {
        if(!!res) throw new Error("Can't determine which state to use for '" + name + "' because there are multiple possibilities:\n" + this);
        res = s.state;
      }
    }
    return res;
  }

  public function get current_exit_path():Array { return _current_exit_path; }
  public function get current_enter_path():Array { return _current_enter_path; }
  public function get current():Superstate { return _current; }
  public function get current_from():Superstate { return _current_from; }
  public function get current_to():Superstate { return _current_to; }

  public function to(state_or_name:*):SuperstateMachine {
    var target:Superstate = state_or_name is Superstate ? state_or_name : stateByName(state_or_name);
    if(!target || target === current) return this; // state not found || already there: do nothing

    _current_from = current;
    _current_to = target;
    var paths:Array = exitAndEnterPathsFromTo(current, target);
    _current_exit_path = paths[0];
    _current_enter_path = paths[1];

    // move along paths
    _current_exit_path.forEach(function(el:Superstate, ...ignore):void { el.onExit(); });
    _current_enter_path.forEach(function(el:Superstate, ...ignore):void { el.onEnter(); });

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
   * @param from      from-state
   * @param to        to-state
   * @return          [states to exit, states to enter]
   */
  public function exitAndEnterPathsFromTo(from:Superstate, to:Superstate):Array {
    if(!to) throw new Error("Superstate: can't find 'to' target state");

    var to_root_path:Array = SuperstateMatchineStatePathInfo(to.machine_path_info).path_from_root;

    if(!from) return [[], to_root_path.concat(to)]; // initial state!
    var from_root_path:Array = SuperstateMatchineStatePathInfo(from.machine_path_info).path_from_root;

    var max_i:int = Math.max(from_root_path.length, to_root_path.length);
    for(var i:int = 0; i < max_i; i++) {
      var cf:Superstate = from_root_path[i];
      var ct:Superstate = to_root_path[i];
      if(cf === ct) continue; // same path, continue
      if(cf === to) {
        // TO is parent of FROM -> go up
        return [from_root_path.slice(i + 1).concat([from]).reverse(),[]];
      }
      if(ct === from) {
        // FROM is parent of TO -> go down
        return [[],to_root_path.slice(i + 1).concat([to])];
      }
      trace("OUT !==" + i);
      return [from_root_path.slice(i).concat([from]).reverse(), to_root_path.slice(i).concat([to])]
    }

    return [[from],[to]];
  }

  private function pathInfoFor(state:Superstate):SuperstateMatchineStatePathInfo {
    if(!state) return null;
    return SuperstateMatchineStatePathInfo(state.machine_path_info);
  }

  public function pathFromRootFor(state:Superstate):Array {
    if(!state) return null;
    return pathInfoFor(state).path_from_root;
  }

  public override function toString():String {
    return _paths.join("\n");
  }
}
}

import de.headjump.superstate.Superstate;

class SuperstateMatchineStatePathInfo {
  private var _me:Superstate;
  private var _path_from_root:Array;
  private var _string_path:String;

  public function SuperstateMatchineStatePathInfo(self:Superstate, path_from_root:Array) {
    _me = self;
    _path_from_root = path_from_root;
    _string_path = ((path_from_root.length > 0) ? "." : "") + path_from_root.map(function(el:Superstate, ...ignore):String { return el.name; }).join(".") + "." + _me.name + "###";
  }

  public function get state():Superstate { return _me; }
  public function get path_from_root():Array { return _path_from_root; }

  public function toString():String { return _string_path.substr(1, -4); }

  public function matches(name:String):Boolean {
    return _string_path.indexOf("." + name + "###") !== -1;
  }
}