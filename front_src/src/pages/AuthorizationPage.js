// flow
import React, { Component } from 'react';
import { Form, Button, message, Spin } from 'antd';
import { observer, inject } from 'mobx-react';

import UserNameField from "../common/components/FormFields/UserAccountFields/UserNameField";
import UserPasswordField from "../common/components/FormFields/UserAccountFields/UserPasswordField";
import UserRepeatPasswordField from "../common/components/FormFields/UserAccountFields/UserRepeatPasswordField";
import UserEmailField from "../common/components/FormFields/UserAccountFields/UserEmailField";
import {handleNonFieldErrors, transferResponseErrorsToForm} from "../common/helpers";

import {ASYNC_STATE, AUTH_FORM_ACTION_TYPES, AUTH_FORM_FIELDS} from "../common/constants";

import type { SettingsStore } from "../stores/settingsStore";

import "./AuthorizationPage.styles.scss";

export const authFormFields = AUTH_FORM_FIELDS;
const actionTypeData = {
  [AUTH_FORM_ACTION_TYPES.register]: {
    headerText: 'Registration',
    formSubmitText: 'Register',
    formActionSwitchText: `Have an Account? Login.`,
  },
  [AUTH_FORM_ACTION_TYPES.login]: {
    headerText: 'Login',
    formSubmitText: 'Login',
    formActionSwitchText: `Don't have an Account yet? Register.`
  }
};

type Props = {
  settingsStore: SettingsStore,
};
type State = {
  showRegisterSuccessMessage: boolean,
};

export class AuthorizationPage extends Component<Props, State> {
  state = {
    showRegisterSuccessMessage: false,
  };
  formId = 'authorization-form';

  registeredUserEmail = '';

  handleUserRegister = () => {
    const { form, settingsStore } = this.props;

    form.validateFields(async (errors, values) => {
      if (!errors) {
        try {
          await settingsStore.userRegister(values);

          this.registeredUserEmail = values[authFormFields.email];
          this.setState({ showRegisterSuccessMessage: true });
        } catch(error) {
          transferResponseErrorsToForm(form, error);
          message.error('Validation error occurred');
        }
      }
    });
  };

  handleUserLogin = () => {
    const { form, settingsStore, history } = this.props;

    form.validateFields(async (errors, values) => {
      if (!errors) {
        try {
          await settingsStore.userLogin(values);

          history.push('/');
        } catch(error) {
          transferResponseErrorsToForm(form, error);
          handleNonFieldErrors(error);
        }
      }
    });
  };

  handleFormActionSwitch = () => {
    const { getFieldValue, setFieldsValue } = this.props.form;

    const { login, register } = AUTH_FORM_ACTION_TYPES;
    const currentFormAction = getFieldValue(AUTH_FORM_FIELDS.formActionType);
    const nextActionType = currentFormAction === login ?
      register : login;

    setFieldsValue({ [AUTH_FORM_FIELDS.formActionType]: nextActionType });
  };

  render() {
    const { showRegisterSuccessMessage } = this.state;
    const { form, settingsStore } = this.props;
    const { getFieldDecorator, getFieldValue } = form;

    getFieldDecorator(authFormFields.formActionType);
    const formAction = getFieldValue(authFormFields.formActionType);
    const {
      headerText,
      formSubmitText,
      formActionSwitchText,
    } = actionTypeData[formAction] || {};
    const isRegister = formAction === AUTH_FORM_ACTION_TYPES.register;
    const handleConfirm = isRegister ? this.handleUserRegister : this.handleUserLogin;

    if (showRegisterSuccessMessage) {
      return (
        <div className="content-outer-container">
          <div id="register-success-info">
            <h2>Registered Successfully</h2>
            <p>Confirmation link is sent to <strong>{this.registeredUserEmail}</strong></p>
            <div>
              <span
                className="link-like"
                onClick={() => {
                  form.setFieldsValue({ [authFormFields.formActionType]: AUTH_FORM_ACTION_TYPES.login });
                  this.setState({ showRegisterSuccessMessage: false });
                }}
              >Go to Login</span>
            </div>
          </div>
        </div>
      );
    }

    return (
      <Spin spinning={settingsStore.asyncState === ASYNC_STATE.pending}>
        <div className="content-outer-container">
          <h1>{headerText}</h1>
          <Form id={this.formId}>
            {isRegister && <UserNameField form={form}/>}

            <UserEmailField form={form}/>

            <UserPasswordField form={form}/>

            {isRegister && <UserRepeatPasswordField form={form}/>}

            <div className="text-align-center" >
              <span className="link-like" onClick={this.handleFormActionSwitch}>
                {formActionSwitchText}
              </span>
            </div>

            <Button type="primary" onClick={handleConfirm}>
              {formSubmitText}
            </Button>

          </Form>
        </div>
      </Spin>
    );
  }
}

const mapPropsToFields = (props) => {
  return {
    [authFormFields.userName]: Form.createFormField({ value: 'dmytro-test-login' }),
    [authFormFields.password]: Form.createFormField({ value: 'abc45678' }),
    [authFormFields.repeatPassword]: Form.createFormField({ value: 'abc45678' }),
    [authFormFields.email]: Form.createFormField({ value: 'test@gmail.com' }),
    [authFormFields.formActionType]: Form.createFormField({ value: AUTH_FORM_ACTION_TYPES.login }),
  };
};

const AuthorizationPageForm = Form.create({
  mapPropsToFields
})(observer(AuthorizationPage));

export default inject('settingsStore')(
  observer(AuthorizationPageForm)
);
