// @flow
import React from 'react';
import {Input, Form} from "antd";

import {AUTH_FORM_FIELDS} from "../../../constants";

const FormItem = Form.Item;
const authFormFields = AUTH_FORM_FIELDS;

type Props = {
  form: {},
  fieldName?: string,
};

export const UserPasswordField = (props: Props) => {
  const {
    form: {
      getFieldDecorator,
    },
    fieldName = authFormFields.password,
  } = props;

  return (
    <FormItem label="Password">
      {getFieldDecorator(fieldName, {
        rules: [
          { required: true, message: 'Password is required.' },
          { min: 8, message: 'Password must contain at least 8 characters.' },
        ]
      })(<Input.Password placeholder="Put password..."/>)}
    </FormItem>
  );
};

export default UserPasswordField;
