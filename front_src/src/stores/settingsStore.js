// @flow
import {action, observable, flow, IObservableValue} from 'mobx';

import type { IObservableObject, IObservableArray } from 'mobx';
import apiService from "../services/apiService";
import {ASYNC_STATE, AUTH_FORM_FIELDS, AUTH_LOCAL_STORAGE_FIELDS} from "../common/constants";
import {safeGetCurrentUserId} from "../common/helpers";

const registerFormFields = AUTH_FORM_FIELDS;

export class SettingsStore {
  @observable asyncState: IObservableValue = ASYNC_STATE.done;
  @observable currentUser: IObservableObject = {
    id: Number(localStorage.getItem(AUTH_LOCAL_STORAGE_FIELDS.userId)),
  };

  @observable allUsers: IObservableArray = [];


  parseRegisterBody = (values) => ({
    username: values[registerFormFields.userName],
    password1: values[registerFormFields.password],
    password2: values[registerFormFields.repeatPassword],
    email: values[registerFormFields.email],
  });

  @action('user register')
  userRegister = flow((function * (formValues) {
    try {
      this.asyncState = ASYNC_STATE.pending;

      const payload = this.parseRegisterBody(formValues);

      yield apiService.registration(payload);

    } catch(error) {
      throw error;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  parseLoginBody = (values: {}) => ({
    email: values[registerFormFields.email],
    password: values[registerFormFields.password],
  });

  @action('user login')
  userLogin = flow((function * (formValues: {}) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const payload = this.parseLoginBody(formValues);

      const { data } = yield apiService.login(payload);
      const { user } = data;

      Object.assign(user, { id: user.pk });

      delete(user.pk);

      this.currentUser = user;

      if (data.token) {
        localStorage.setItem(AUTH_LOCAL_STORAGE_FIELDS.userId, user.id);
        localStorage.setItem(AUTH_LOCAL_STORAGE_FIELDS.token, data.token);
      }
    } catch(error) {
      throw error;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('user logout')
  userLogout = () => {
    this.currentUser = {};

    localStorage.removeItem(AUTH_LOCAL_STORAGE_FIELDS.userId);
    localStorage.removeItem(AUTH_LOCAL_STORAGE_FIELDS.token);
  };

  @action('get my user')
  getMyUser = flow((function * () {
    try {
      this.asyncState = ASYNC_STATE.pending;

      const currentUserId = safeGetCurrentUserId();

      if (currentUserId) {
        const { data } = yield apiService.getUserById(currentUserId);

        this.currentUser = data;
      }
    } catch(error) {
      throw error;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('update profile')
  updateProfile = flow((function * (body: {}) {
    try {
      this.asyncState = ASYNC_STATE.pending;

      const currentUserId = safeGetCurrentUserId();
      const { data } = yield apiService.updateProfile(currentUserId, body);

      this.currentUser = data;
    } catch(error) {
      throw error;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('change password')
  changePassword = flow((function * (body: {}) {
    try {
      this.asyncState = ASYNC_STATE.pending;

      yield apiService.changePassword(body);
    } catch(error) {
      throw error;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('get users')
  getUsers = flow((function * () {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const { data } = yield apiService.getUsers();

      this.allUsers = data;
    } catch (error) {
      throw error;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  // @action('users search')
  // searchUsers = flow((function * (name: string) {
  //   this.asyncState = ASYNC_STATE.pending;
  //
  //   try {
  //     const { data } = yield apiService.searchUsers(name);
  //
  //     console.log(data);
  //   } catch (error) {
  //     throw error;
  //   } finally {
  //     this.asyncState = ASYNC_STATE.done;
  //   }
  // }).bind(this));
}

export default new SettingsStore();
