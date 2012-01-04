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

    eq(s_idle.name, "", "init name blank");

    var m:SuperstateMachine = new SuperstateMachine({
      idle: s_idle,
      something: new Superstate(null, {
        deep: s_deep
      })
    });

    eq(s_idle.name, "idle", "machine sets names");
    eq(s_deep.name, "deep", "machine sets deep names");

    eq(m.stateByName("idle"), s_idle, "find 'idle'");
  }
}
}