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

export const UserEmailField = (props: Props) => {
  const {
    form: {
      getFieldDecorator,
    },
    fieldName = authFormFields.email,
  } = props;

  return (
    <FormItem label="Email">
      {getFieldDecorator(fieldName, {
        rules: [
          { required: true, message: 'Email is required.' }
        ]
      })(<Input placeholder="Put email..."/>)}
    </FormItem>
  );
};

export default UserEmailField;
