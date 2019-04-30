// @flow
import React, { PureComponent } from 'react';

type Props = {
  renderRows: () => React.node,
};
type State = {
  selectedRow?: number,
};

export class WithSelectableRow extends PureComponent<Props, State> {
  state = {
    selectedRow: null,
  };

  handleRowSelect = (selectedRow: number): void => this.setState({ selectedRow });

  render() {
    return this.props.renderRows(
      this.state.selectedRow,
      this.handleRowSelect,
    );
  }
}