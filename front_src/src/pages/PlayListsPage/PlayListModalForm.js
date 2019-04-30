import React, { Component } from 'react';
import { Modal } from 'antd';

import PlayListDataForm from "../../common/components/PlayListDataForm/PlayListDataForm";

type Props = {
  visible: boolean,
  hideModal: () => void,
  handleOk: () => void,
  isCreateForm: boolean,
  playListItem?: {},
};

export class PlayListModalForm extends Component<Props> {
  handleFormSubmit = (values) => {
    const { hideModal, handleOk } = this.props;
    // console.log('This is form submit handler');
    // console.log(values);

    handleOk(values);
    hideModal();
  };

  render() {
    const { visible, hideModal, isCreateForm, playListItem } = this.props;

    return (
      <Modal
        visible={visible}
        maskClosable={false}
        footer={null}
        onCancel={hideModal}
        wrapClassName="avoid-dz-player-modal custom-scroll-bar"
        width='80vw'
      >
        <h2>{isCreateForm ? 'New Playlist' : 'Edit Playlist'}</h2>
        <PlayListDataForm
          isCreateForm={isCreateForm}
          playListItem={playListItem}
          handleSubmit={this.handleFormSubmit}
        />
      </Modal>
    );
  }
}

export default PlayListModalForm;
