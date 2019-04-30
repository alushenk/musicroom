import React, { Component } from "react";
import {Button, Form, message, Spin} from "antd";
import {inject, observer} from "mobx-react";
import { toJS } from 'mobx';

import {handleNonFieldErrors, transferResponseErrorsToForm} from "../../common/helpers";
import UserNameField from "../../common/components/FormFields/UserAccountFields/UserNameField";
import UserPasswordField from "../../common/components/FormFields/UserAccountFields/UserPasswordField";
import UserRepeatPasswordField from "../../common/components/FormFields/UserAccountFields/UserRepeatPasswordField";

import {ASYNC_STATE, PROFILE_FORM_FIELDS} from "../../common/constants";

import type {SettingsStore} from "../../stores/settingsStore";

const profileFormFields = PROFILE_FORM_FIELDS;
const passwordChangeFields = [
  profileFormFields.newPassword,
  profileFormFields.repeatNewPassword,
];
const userInfoFields = [
  profileFormFields.firstName,
  profileFormFields.secondName,
];

type Props = {
  settingsStore: SettingsStore,
};

export class ProfilePage extends Component<Props, State> {
  formId = 'profile-form';

  handleFormConfirm = (isPasswordChange: boolean = false) => {
    const { form, settingsStore } = this.props;

    const [ fieldsToValidate, fieldsToReset ] = isPasswordChange ? [
      passwordChangeFields,
      userInfoFields,
    ] : [
      userInfoFields,
      passwordChangeFields,
    ];

    const fieldsToSet = fieldsToReset.reduce((acc, fieldName) => ({
      ...acc,
      [fieldName]: { value: form.getFieldValue(fieldName), errors: null },
    }), {});

    form.validateFields(fieldsToValidate, async (errors, values) => {
      if (!errors) {
        try {

          if (isPasswordChange) {
            await settingsStore.changePassword(values);
          } else {
            await settingsStore.updateProfile(values);
          }

          message.success(`${isPasswordChange ? 'Password' : 'Profile data'} updated successfully.`);
        } catch(error) {
          transferResponseErrorsToForm(form, error);
          handleNonFieldErrors(error)
        } finally {
          form.setFields(fieldsToSet);
        }
      }
    });
  };

  render() {
    const { form, settingsStore } = this.props;

    return (
      <Spin spinning={settingsStore.asyncState === ASYNC_STATE.pending}>
        <div className="content-outer-container dz-player-avoiding-view">
          <h1>My Profile</h1>
          <Form id={this.formId}>
            <UserNameField
              form={form}
              fieldName={profileFormFields.firstName}
              placeholder={'First name...'}
            />

            <UserNameField
              form={form}
              fieldName={profileFormFields.secondName}
              placeholder={'Second name...'}
            />

            <Button type="primary" onClick={() => this.handleFormConfirm()}>
              Update Profile
            </Button>

            <UserPasswordField form={form} fieldName={profileFormFields.newPassword}/>

            <UserRepeatPasswordField
              form={form}
              fieldName={profileFormFields.repeatNewPassword}
              validateToMatchFieldName={profileFormFields.newPassword}
            />

            <Button type="primary" onClick={() => this.handleFormConfirm(true)}>
              Change Password
            </Button>

            <Button
              id="deezer-account-button"
              type="primary"
              onClick={() => {
                window.DZ.login((response) => {
                  if (response.authResponse) {
                    window.DZ.api('/user/me', (response) => {
                      console.log('Good to see you, ' + response.name + '.');
                    });
                  } else {
                    console.warn('User cancelled login or did not fully authorize.');
                  }
                }, { perms: 'basic_access,email' });
              }}
            >Connect Deezer Account</Button>
          </Form>
        </div>
      </Spin>
    );
  }
}

const mapPropsToFields = (props) => {
  const { settingsStore } = props;
  const currentUser = toJS(settingsStore.currentUser);

  console.log('Map Props To Fields');

  const {
    firstName,
    secondName,
  } = profileFormFields;

  return {
    [firstName]: Form.createFormField({ value: currentUser[firstName] }),
    [secondName]: Form.createFormField({ value: currentUser[secondName] }),

    [profileFormFields.newPassword]: Form.createFormField({ value: '' }),
    [profileFormFields.repeatNewPassword]: Form.createFormField({ value: '' }),
  };
};

const ProfilePageForm = Form.create({
  mapPropsToFields
})(observer(ProfilePage));

export default inject('settingsStore')(
  observer(ProfilePageForm)
);
