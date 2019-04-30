
import { action, observable, runInAction } from 'mobx';

export class SandboxStore {
  @observable items = [];

  @action('set items using value')
  setItems = async (newItems) => {
    runInAction('setting items', () => {
      this.items = newItems;
    });
  }
}

export default new SandboxStore();
