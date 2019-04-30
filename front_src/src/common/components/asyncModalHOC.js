import React from 'react';
import {Input, Modal} from "antd";

export const asyncModalHOC = function(WrappedComponent) {
  return class extends React.PureComponent {
    renderAsyncModal(modalProps) {
      const { password, asyncModalVisible } = this.state;

      const close = () => this.setState({ asyncModalVisible: false });

      return asyncModalVisible ? (
        <Modal
          title='Master password'
          okText='Confirm'
          okButtonProps={{
            disabled: !password
          }}
          {...modalProps}
          visible={true}
          closable
          onCancel={() => {
            this.promiseRejectRef('Password Modal Canceled');
            close();
          }}
          onOk={() => {
            this.promiseResolveRef(password);
            close();
          }}
        >
          <div>
            <p>Please provide master password</p>
            <Input autoFocus value={password} type="password" onChange={(e) => this.setState({ password: e.target.value })} />
          </div>
        </Modal>
      ) : null;
    };

    render() {
      return (
        <WrappedComponent
          makeNoise={this.makeNoise}
          renderAsyncModal={this.renderAsyncModal}
          {...this.props}
        />
      );
    }
  }
};

export default asyncModalHOC;
