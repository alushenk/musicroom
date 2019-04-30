import React, {PureComponent} from 'react';
import { Button } from 'antd';

import api from '../../services/apiService';
import asyncModalHOC from "./asyncModalHOC";

import './AsyncModalSample.style.scss';

class AsyncModalSample extends PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      backgroundColor: 'grey',
      password: null,
      asyncModalVisible: false,
    };

    this.passwordModalPromise = null;
    this.promiseResolveRef = null;
    this.promiseRejectRef = null;

    this.renderAsyncModal = this.props.renderAsyncModal.bind(this);
  }

  async componentDidMount() {
    console.log('Component did mount');
    try {
      const response = await api.registration({
        userName: 'Dmytro',
        email: 'bezsinnyi91@gmail.com',
        password1: '111111',
        password2: '111111',
      });
      console.log(response);
    } catch (e) {
      console.warn(e);
    }
  }

  handleClick = async () => {
    this.setState({ backgroundColor: 'grey' });
    setTimeout(() => this.setState({ backgroundColor: 'green' }), 2000);

    this.passwordModalPromise = null;

    this.passwordModalPromise = new Promise((resolve, reject) => {
      this.promiseResolveRef = resolve;
      this.promiseRejectRef = reject;
    });

    this.setState({ asyncModalVisible: true });

    try {
      const formPassword = await this.passwordModalPromise;
      console.log(formPassword);
    } catch(e) {
      console.warn(e);
    }
    console.log(this.state.password);
  };

  render() {
    const {
      backgroundColor
    } = this.state;

    return (
      <div className='async-modal-sample-container' style={{ backgroundColor: backgroundColor }}>
        <div>Async Modal Sample Component</div>
        {this.renderAsyncModal()}
        <Button type='primary' onClick={this.handleClick}>Click</Button>
      </div>
    );
  }
}

export default asyncModalHOC(AsyncModalSample);
