package de.headjump.superstate.test {
import de.headjump.superstate.Superstate;
import de.headjump.superstate.SuperstateMachine;
import de.headjump.tests.OkTest;

public class TestSuperstate extends OkTest {
  public function TestSuperstate(test_method:String = null) {
    super(test_method);
  }

  public function testInitVals():void {
    var m:SuperstateMachine = new SuperstateMachine({});
    nok(!!m.current, "init vals all null");
    nok(!!m.current_enter_path);
    nok(!!m.current_exit_path);
    nok(!!m.current_from);
    nok(!!m.current_to);
  }

  public function testByName():void {
    var s_idle:Superstate = new Superstate();
    var s_deep:Superstate = new Superstate();
    var s_parent:Superstate;

    eq(s_idle.name, "", "init name blank");

    var m:SuperstateMachine = new SuperstateMachine({
      idle: s_idle,
      something: s_parent = new Superstate(null, {
        deep: s_deep
      })
    });

    eq(s_idle.name, "idle", "machine sets names");
    eq(s_deep.name, "deep", "machine sets deep names");
    eq(s_parent.name, "something", "machine sets deep names");

    eq(m.stateByName("idle"), s_idle, "find 'idle'");
    eq(s_deep, m.stateByName("something.deep"), "find with parent");
    eq(s_parent, m.stateByName("something"), "find parent");
    neq(s_deep, m.stateByName("something.bla.deep"), "unfind with wrong parent");
    neq(s_deep, m.stateByName("thing.deep"), "unfind with wrong parent");
    neq(s_deep, m.stateByName("deep.bla"), "unfind with wrong parent");
  }

  public function testErrorWhenNameNotDistinct():void {
    var m:SuperstateMachine = new SuperstateMachine({
      parent: new Superstate(null, {
        child: new Superstate(null, {
          child: new Superstate()
        })
      })
    });

    raises(Error, function():void {
      m.stateByName("child");
    });
  }

  public function testPathFromRoot():void {
    var m:SuperstateMachine = new SuperstateMachine({
      one: new Superstate(null, {
        two: new Superstate(null, {
          three: new Superstate()
        })
      })
    });

    ok(!!m.stateByName("three"));
    var p:Array = m.pathFromRootFor(m.stateByName("three"));
    eqArray(p, [m.stateByName("one"), m.stateByName("two")], "Path from root in order without self");

    p = m.pathFromRootFor(m.stateByName("one"));
    eqArray(p, [], "empty path from root without self");
  }
}
}